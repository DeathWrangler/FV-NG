package Managers.Clubs.DataObjects
{
   public interface IFarmClubObject
   {
      
      function get isLoaded() : Boolean;
      
      function get isPending() : Boolean;
      
      function setIsPending() : void;
      
      function setDirty() : void;
      
      function get isStale() : Boolean;
      
      function get data() : *;
      
      function onLoadData(param1:Object) : void;
   }
}

