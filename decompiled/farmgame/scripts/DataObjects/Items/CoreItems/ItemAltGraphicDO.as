package DataObjects.Items.CoreItems
{
   import DataObjects.BaseDataObject;
   
   public class ItemAltGraphicDO extends BaseDataObject
   {
      
      public var graphic:String;
      
      public function ItemAltGraphicDO()
      {
         super();
      }
      
      override public function toString() : String
      {
         return _toString(this.graphic);
      }
   }
}

