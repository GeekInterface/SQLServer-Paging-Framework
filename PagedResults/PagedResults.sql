
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[PagedResults]

      @TableName varchar(50),
      @OrderBy varchar(Max),
      @Columns varchar(Max)='*',
      @pageNumber bigint = 1, 
      @pageSize Bigint = 10
AS

 BEGIN

SET NOCOUNT ON;

DECLARE @StartRow_Id bigint
DECLARE @EndRow_Id bigint


SET @StartRow_Id = ((@pageNumber - 1) * @pageSize) + 1
SET @EndRow_Id = (@StartRow_Id + @pageSize) - 1

SET @Columns = NULLIF(@Columns, '')
SET @Columns = ISNULL(@Columns, '*')

DECLARE @statement varchar(max);

SET @statement = '
 Declare @TotalRows int;
 Declare @TotalPages int;
 Select @TotalRows =Count(*) from  ' + @TableName + ';
 Set @TotalPages =  CEILING(Cast(@TotalRows as Decimal)/' + CAST(@pageSize AS varchar) + ')
 Select  ROW_NUMBER()OVER (order by ' + @OrderBy + ') as Row_Id , @TotalRows as TotalRows, ' + @Columns + ' Into #PagedData from  ' + @TableName + '; 

                           Select ' + CAST(@pageNumber AS varchar) + ' as PageNumber, @TotalPages  as TotalPages, ' + CAST(@pageSize AS varchar) + ' as PageSize, * from #PagedData Where Row_ID Between ' + CAST(@StartRow_Id AS varchar) + ' and ' + CAST(@EndRow_Id AS varchar) + ' order by Row_ID; 

                           Drop Table #PagedData; '
EXEC (@statement)



END