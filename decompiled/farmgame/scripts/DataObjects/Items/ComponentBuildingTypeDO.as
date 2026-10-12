package DataObjects.Items
{
   import DataObjects.BaseDataObject;
   
   public class ComponentBuildingTypeDO extends BaseDataObject
   {
      
      public var type:String;
      
      public function ComponentBuildingTypeDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.type);
      }
   }
}

