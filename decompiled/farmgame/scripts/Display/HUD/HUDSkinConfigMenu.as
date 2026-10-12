package Display.HUD
{
   public class HUDSkinConfigMenu
   {
      
      private static const ATTR_NAME:String = "@name";
      
      public static const ATTR_ASSET_TAG:String = "@assetTag";
      
      public static const NODE_COLUMNS:String = "columns";
      
      private static const NODE_TERRAINS:String = "terrains";
      
      public static const PROP_ASSET_TAG:String = "assetTag";
      
      private var m_name:String = null;
      
      private var m_columns:Array = null;
      
      public function HUDSkinConfigMenu(menuXML:XML)
      {
         var columnXML:XML = null;
         var colObj:Object = null;
         var terrainsArray:Array = null;
         var terrainXML:XML = null;
         super();
         this.m_name = menuXML[ATTR_NAME];
         if(menuXML.hasOwnProperty(NODE_COLUMNS))
         {
            this.m_columns = new Array();
            for each(columnXML in menuXML.columns.column)
            {
               colObj = new Object();
               colObj[PROP_ASSET_TAG] = String(columnXML[ATTR_ASSET_TAG]);
               if(columnXML.hasOwnProperty(NODE_TERRAINS))
               {
                  terrainsArray = new Array();
                  for each(terrainXML in columnXML.terrains.terrain)
                  {
                     terrainsArray.push(terrainXML.toString());
                  }
                  colObj[NODE_TERRAINS] = terrainsArray;
               }
               this.m_columns.push(colObj);
            }
         }
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get columns() : Array
      {
         return this.m_columns;
      }
      
      public function totalColumns() : int
      {
         var result:int = 0;
         if(this.m_columns)
         {
            result = int(this.m_columns.length);
         }
         return result;
      }
      
      public function getColumnAssetTag(columnIndex:int) : String
      {
         var result:String = null;
         if(Boolean(this.m_columns && columnIndex >= 0) && Boolean(columnIndex < this.m_columns.length) && Boolean(this.m_columns[columnIndex].hasOwnProperty(PROP_ASSET_TAG)))
         {
            result = this.m_columns[columnIndex][PROP_ASSET_TAG];
         }
         return result;
      }
      
      public function getColumnTerrainNames(columnIndex:int) : Array
      {
         var result:Array = null;
         if(Boolean(this.m_columns && columnIndex >= 0) && Boolean(columnIndex < this.m_columns.length) && Boolean(this.m_columns[columnIndex].hasOwnProperty(NODE_TERRAINS)))
         {
            result = this.m_columns[columnIndex][NODE_TERRAINS];
         }
         return result;
      }
   }
}

