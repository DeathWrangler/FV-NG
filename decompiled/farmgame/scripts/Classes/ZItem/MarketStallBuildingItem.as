package Classes.ZItem
{
   import Classes.Constants.WorldsConstants;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class MarketStallBuildingItem extends BuildingItem
   {
      
      public function MarketStallBuildingItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function get iconUrl() : String
      {
         return Global.getAssetURL(this.iconRelativeUrl);
      }
      
      override public function get iconRelativeUrl() : String
      {
         var result:String = null;
         var imagesArr:Array = null;
         var len:int = 0;
         var checkName:String = null;
         var urlFound:Boolean = false;
         var imageName:String = null;
         var curDataSource:BaseDataSource = null;
         var i:int = 0;
         var images:XMLList = null;
         var currentWorldType:String = Global.worldManager.currentWorldType;
         if(currentWorldType != WorldsConstants.WORLD_ID_HOME)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               imagesArr = m_dataSource.getArray("image");
               len = int(imagesArr.length);
               checkName = "icon_" + currentWorldType;
               urlFound = false;
               for(i = 0; i < len; i++)
               {
                  curDataSource = imagesArr[i] as BaseDataSource;
                  imageName = curDataSource.getString("name");
                  if(imageName == checkName)
                  {
                     result = curDataSource.getString("url");
                     urlFound = true;
                     break;
                  }
               }
               if(!urlFound)
               {
                  result = super.iconRelativeUrl;
               }
            }
            else
            {
               images = m_itemXML.image.(@name == "icon_" + currentWorldType);
               if(images.length())
               {
                  result = images[0].@url;
               }
               else
               {
                  result = super.iconRelativeUrl;
               }
            }
         }
         else
         {
            result = super.iconRelativeUrl;
         }
         return result;
      }
      
      override public function get cost() : int
      {
         var costString:String = null;
         var tierDataDS:BaseDataSource = null;
         var tierDataXml:XML = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(Boolean(m_dataSource) && isTiered)
            {
               tierDataDS = getItemTierDS(m_dataSource,0);
               if(tierDataDS != null)
               {
                  costString = getDataProperty(tierDataDS,"cost");
               }
               else
               {
                  costString = getDataProperty(m_dataSource,"cost");
               }
            }
            else
            {
               costString = getDataProperty(m_dataSource,"cost");
            }
         }
         else if(isTiered)
         {
            tierDataXml = getItemTier(m_itemXML,1);
            if(tierDataXml != null)
            {
               costString = getXMLProperty(tierDataXml,"cost");
            }
            else
            {
               costString = getXMLProperty(m_itemXML,"cost");
            }
         }
         else
         {
            costString = getXMLProperty(m_itemXML,"cost");
         }
         if(costString)
         {
            m_cost = int(costString);
         }
         else
         {
            m_cost = 0;
         }
         var altPrice:int = testForVariablePricing();
         if(altPrice > 0)
         {
            m_cost = altPrice;
         }
         return m_cost;
      }
   }
}

