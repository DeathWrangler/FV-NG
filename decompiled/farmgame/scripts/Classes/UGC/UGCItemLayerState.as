package Classes.UGC
{
   import Classes.ZItem.FarmItem;
   
   public class UGCItemLayerState
   {
      
      private var m_itemCode:String;
      
      private var m_color:uint;
      
      public function UGCItemLayerState(itemCode:String = null, color:uint = 16777216)
      {
         super();
         this.m_itemCode = itemCode;
         this.m_color = color;
      }
      
      public static function createFromServerState(data:Object) : UGCItemLayerState
      {
         var state:UGCItemLayerState = new UGCItemLayerState();
         state.loadData(data);
         return state;
      }
      
      public function clone() : UGCItemLayerState
      {
         return createFromServerState(this.packData());
      }
      
      public function loadData(data:Object) : void
      {
         this.m_itemCode = null;
         this.m_color = UGCConstants.COLOR_UNSET;
         if(data)
         {
            if(data[UGCConstants.DATA_KEY_ITEMCODE])
            {
               this.m_itemCode = data[UGCConstants.DATA_KEY_ITEMCODE] as String;
            }
            if(data[UGCConstants.DATA_KEY_COLOR])
            {
               try
               {
                  this.m_color = uint(data[UGCConstants.DATA_KEY_COLOR]);
                  if(this.m_color >= UGCConstants.COLOR_UNSET)
                  {
                     this.m_color = UGCConstants.COLOR_UNSET;
                     GlobalEngine.error("UGC","Invalid color when parsing state: " + data[UGCConstants.DATA_KEY_COLOR]);
                  }
               }
               catch(e:Error)
               {
                  GlobalEngine.error("UGC","Error parsing color for state: " + data[UGCConstants.DATA_KEY_COLOR]);
               }
            }
         }
      }
      
      public function packData() : Object
      {
         var data:Object = new Object();
         if(this.m_itemCode != null && this.m_itemCode != "")
         {
            data[UGCConstants.DATA_KEY_ITEMCODE] = this.m_itemCode;
         }
         if(this.isCustomColor)
         {
            data[UGCConstants.DATA_KEY_COLOR] = this.m_color.toString();
         }
         return data;
      }
      
      public function get itemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function set itemCode(value:String) : void
      {
         if(this.m_itemCode != value)
         {
            this.m_itemCode = value;
            if(this.isCustomColor)
            {
               this.clearCustomColor();
            }
         }
      }
      
      public function get item() : FarmItem
      {
         var result:FarmItem = null;
         if(this.isCustomItem)
         {
            result = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         }
         return result;
      }
      
      public function get isCustom() : Boolean
      {
         return this.isCustomItem || this.isCustomColor;
      }
      
      public function get isCustomItem() : Boolean
      {
         return this.m_itemCode != null && this.m_itemCode != "";
      }
      
      public function get color() : uint
      {
         return this.m_color;
      }
      
      public function set color(value:uint) : void
      {
         this.m_color = value < UGCConstants.COLOR_UNSET ? value : UGCConstants.COLOR_UNSET;
      }
      
      public function get isCustomColor() : Boolean
      {
         return this.m_color < UGCConstants.COLOR_UNSET;
      }
      
      public function clearCustomColor() : void
      {
         this.m_color = UGCConstants.COLOR_UNSET;
      }
   }
}

