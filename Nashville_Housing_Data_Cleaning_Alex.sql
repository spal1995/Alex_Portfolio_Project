
Select * from Portfolio.NashvilleData

-- Standardized Date Format
Select Saledate, CONVERT(Date,Saledate) from Portfolio.NashvilleData;

Update Portfolio.NashvilleData
SET Saledate=CONVERT(Date,Saledate);

-- Populate Property Address Data
Select * from Portfolio.NashvilleData where PropertyAddress IS NULL


-- Self Joining to check if any row has the same parcelID but different
-- uniqueID then populate the address corresponding to the parcelID in a 
--different row having the parcelID same but the Address as NULL
-- ISNULL function replaces the NULL values with the correct value
Select 
A.UniqueID,A.PArcelID,B.UniqueID,B.ParcelID,A.PropertyAddress,B.PropertyAddress,
ISNULL(B.PropertyAddress,A.PropertyAddress)
from Portfolio.NashvilleData A
JOIN Portfolio.NashvilleData B
on A.ParcelID=B.ParcelID
and A.UniqueID<>B.UniqueID
where B.PropertyAddress IS NULL;

Update B
SET PropertyAddress = ISNULL(B.PropertyAddress,A.PropertyAddress)
from Portfolio.NashvilleData A
JOIN Portfolio.NashvilleData B
on A.ParcelID=B.ParcelID
and A.UniqueID<>B.UniqueID
where B.PropertyAddress IS NULL;

-- Breaking the address in sections like state city
Select PropertyAddress from Portfolio.NashvilleData

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from Portfolio.NashvilleData

ALTER TABLE Portfolio.NashvilleData
Add PropertySplitAddress NVARCHAR(255)

ALTER TABLE Portfolio.NashvilleData
Add PropertySplitCity NVARCHAR(255)

Update A
SET A.PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
from Portfolio.NashvilleData A

Update A
SET A.PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from Portfolio.NashvilleData A

---- OWNER ADDRESS CORRECTION
Select OwnerAddress From Portfolio.NashvilleData

-- Breaking the address with PARSENAME (parsename usually used . to parse but we will see how to do it by commas also)
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Portfolio.NashvilleData

ALTER TABLE Portfolio.NashvilleData
Add OwnerSplitAddress NVARCHAR(255)

ALTER TABLE Portfolio.NashvilleData
Add OwnerSplitCity NVARCHAR(255)

ALTER TABLE Portfolio.NashvilleData
Add OwnerSplitState NVARCHAR(255)

Update A
SET A.OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
from Portfolio.NashvilleData A

Update A
SET A.OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
from Portfolio.NashvilleData A

Update A
SET A.OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Portfolio.NashvilleData A


--- Correcting Column to one specific value when it has multiple variable like N and No to represent the same thing

Select Distinct(SoldAsVacant),Count(SoldAsVacant) from Portfolio.NashvilleData
Group by SoldAsVacant
order by 2

Select SoldAsVacant
,CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
     ELSE SoldAsVacant
     END
from Portfolio.NashvilleData

Update Portfolio.NashvilleData
SET SoldAsVacant= CASE WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
     ELSE SoldAsVacant
     END

-- Removing Duplicates
Select *, ROW_NUMBER() 
OVER(PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
from Portfolio.NashvilleData

-- CTE to check RowNumber > 1 and delete them
WITH DUPLICATE_FIND AS (
  Select *, ROW_NUMBER() 
OVER(PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
from Portfolio.NashvilleData
)
SELECT * from DUPLICATE_FIND where row_num > 1

--- Delete Unused Column
ALTER TABLE Portfolio.NashvilleData
DROP COLUMN TaxDistrict