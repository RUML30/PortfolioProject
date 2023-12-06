SELECT *
FROM NashvilleHousingDataset


SELECT *
FROM NashvilleHousingDataset
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- FILLED NULL VALUES IN PROPERTY ADDRESS
SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress, ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM NashvilleHousingDataset AS T1
JOIN NashvilleHousingDataset AS T2
	ON T1.ParcelID = T2.ParcelID
	AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL


UPDATE T1 
SET PropertyAddress = ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM NashvilleHousingDataset T1
JOIN NashvilleHousingDataset T2
	ON T1.ParcelID = T2.ParcelID
	AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL


-- SPLITTING PROPERTY ADDRESS TO MAKE IT MORE USABLE

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS City
FROM NashvilleHousingDataset

ALTER TABLE NashvilleHousingDataset
Add PropertySplitAddress Nvarchar (255);

UPDATE NashvilleHousingDataset
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )

ALTER TABLE NashvilleHousingDataset
Add PropertySplitCity Nvarchar (255);

UPDATE NashvilleHousingDataset
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




-- SPLITTING OWNER'S ADDRESS TO MAKE IT MORE USABLE
SELECT OwnerAddress
FROM NashvilleHousingDataset


SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingDataset

ALTER TABLE NashvilleHousingDataset
Add OwnerSplitAddress Nvarchar (255);

UPDATE NashvilleHousingDataset
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingDataset
Add OwnerSplitCity Nvarchar (255);

UPDATE NashvilleHousingDataset
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingDataset
Add OwnerSplitState Nvarchar (255);

UPDATE NashvilleHousingDataset
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- CHANGE THE 'Y' AND 'N' TO 'YES' AND 'NO'
SELECT DISTINCT
	(SoldAsVacant), 
	COUNT(SoldAsVacant)
FROM NashvilleHousingDataset
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousingDataset

UPDATE NashvilleHousingDataset
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- DELETE DUPLICATES
WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() 
		OVER (
		PARTITION BY
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
		ORDER BY 
			UniqueID
			) row_num
FROM NashvilleHousingDataset
--ORDER BY ParcelID
)
--DELETE 
SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
ORDER BY PropertyAddress
---- uncommenting the comments deletes the duplicates


-- DELETING UNWANTED COLUMNS

ALTER TABLE NashVilleHousingDataset
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
