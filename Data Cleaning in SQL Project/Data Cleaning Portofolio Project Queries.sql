
-- Step 1: Load and inspect the raw data
SELECT *
FROM NashvilleHousing;

-- This gives a full preview of the dataset so we can see column names, data types, and any obvious issues.
-- The table contains property sales data from Nashville with fields such as property address, sale date, price, etc.


-- Step 2: Standardize date format
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing;

-- This converts the sale date from its original format to a standard DATE type for easier filtering and sorting.

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

-- Now we update the original `SaleDate` column to use the standardized date format.


-- Step 3: Populate missing Property Address data
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

-- This identifies all rows with missing property addresses.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Here we join the table with itself on ParcelID to find matches where the property address exists for the same parcel elsewhere.

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- This fills in missing property addresses by using the known value from another record with the same ParcelID.


-- Step 4: Split PropertyAddress into separate columns
SELECT PropertyAddress
FROM NashvilleHousing;

SELECT
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing;

-- Splits the full PropertyAddress into "Address" and "City" parts.

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Adds and populates two new columns: one for the street address and another for the city.


-- Step 5: Split OwnerAddress in the same way
SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing;

-- Uses `PARSENAME` (typically for parsing object names) creatively to split the OwnerAddress into Street, City, and State.

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Adds and populates new columns for owner's street address, city, and state.


-- Step 6: Normalize "SoldAsVacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;

-- Identifies inconsistent entries like 'Y', 'Yes', 'N', 'No'

UPDATE NashvilleHousing
SET SoldAsVacant = 
  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END;

-- Replaces 'Y' and 'N' with 'Yes' and 'No' to standardize the field.


-- Step 7: Remove duplicates
WITH RowNumCTE AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
           ORDER BY UniqueID
         ) AS row_num
  FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

-- Identifies and deletes duplicate rows based on key property fields.


-- Step 8: Remove unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

-- Cleans up by removing redundant or already-split fields.
