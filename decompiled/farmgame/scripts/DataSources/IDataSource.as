package DataSources
{
   public interface IDataSource
   {
      
      function getData(... rest) : *;
      
      function getArray(... rest) : Array;
      
      function hasData(... rest) : Boolean;
   }
}

