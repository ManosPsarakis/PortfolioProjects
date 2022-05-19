

--Cleaning Data in SQL Queries


Select *
from [Portofolio Project.1]..NashvilleHousing

--Standarize Date Fromat

Select SaleDate, CONVERT(Date,SaleDate)
From [Portofolio Project.1]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date


Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Portofolio Project.1]..NashvilleHousing


-- Populate Property Address data

Select *
From [Portofolio Project.1]..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portofolio Project.1]..NashvilleHousing a 
Join [Portofolio Project.1]..NashvilleHousing b 
      on a.ParcelID = b.ParcelID
	  AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portofolio Project.1]..NashvilleHousing a 
Join [Portofolio Project.1]..NashvilleHousing b 
      on a.ParcelID = b.ParcelID
	  AND a.[UniqueID ] <> b.[UniqueID ]



-- Breaking out Address into Individual Columns (Address, City, State)

	  
Select PropertyAddress
From [Portofolio Project.1]..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From [Portofolio Project.1]..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From [Portofolio Project.1]..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);


Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);


Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From [Portofolio Project.1]..NashvilleHousing




Select OwnerAddress
From [Portofolio Project.1]..NashvilleHousing


Select
PARSENAME(REPLACE (OwnerAddress, ',', '.') , 3 ),
PARSENAME(REPLACE (OwnerAddress, ',', '.') , 2 ),
PARSENAME(REPLACE (OwnerAddress, ',', '.') , 1 )
From [Portofolio Project.1]..NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);


Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.') , 3 )


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);


Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.') , 2 )



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);


Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.') , 1 )



Select *
From [Portofolio Project.1]..NashvilleHousing



--Change Y and N to Yes and No in the "SoldAsVacant" field


Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Portofolio Project.1]..NashvilleHousing
Group By SoldAsVacant
order by 2


Select SoldAsVacant,
Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
From [Portofolio Project.1]..NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END


--Remove Duplicates


With RowNumCTE AS (
Select *,
ROW_NUMBER() Over (
Partition By ParcelID,
PropertyAddress, 
SalePrice,
SaleDate,
LegalReference
Order BY UniqueID
) row_num
From [Portofolio Project.1]..NashvilleHousing
)


Delete 
From RowNumCTE
where row_num > 1




--Delete Unused Columns



Select *
From [Portofolio Project.1]..NashvilleHousing


Alter Table NashvilleHousing
Drop column	OwnerAddress, TaxDistrict, PropertyAddress



Alter Table NashvilleHousing
Drop column	SaleDate


