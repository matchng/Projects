SELECT * FROM NashvilleHousing;


--Standardise Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM NashvilleHousing;

-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


SELECT PARSENAME(replace(OwnerAddress,',','.'), 3) as Address,
	PARSENAME(replace(OwnerAddress,',','.'), 2) as City,
	PARSENAME(replace(OwnerAddress,',','.'), 1) as State
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3)  

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1)

SELECT * from NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


-- Remove Duplicates

SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
				 UniqueID) as row_num
FROM NashvilleHousing
ORDER BY ParcelID;

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
				 UniqueID) as row_num
FROM NashvilleHousing)
DELETE FROM RowNumCTE
WHERE row_num > 1;


-- Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress,
			OwnerAddress,
			TaxDistrict,
			SaleDate;

SELECT * FROM PortfolioProject..NashvilleHousing;
