package Classes.ZItem
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.XMLKeys;
   import Classes.DataSources.XMLDataSource;
   import Classes.util.FarmGameUtil;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import Managers.PerformanceExperimentManager;
   import Managers.UGCDecoManager;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   
   public class ZItemBase implements IExternalizable
   {
      
      public static const MASTERY_ICON_KEY:String = "masteredItem";
      
      public static const CMS_PRE_COMMIT_DATA_KEY:String = "preCommitData";
      
      public static const SWF_PLACEHOLDER_ASSET_KEY:String = "placeholderAssetExportName";
      
      public static const NAME_LIMIT_TYPE:String = "name";
      
      public static const CODE_LIMIT_TYPE:String = "code";
      
      public static const BUILDING_NAME_LIMIT_TYPE:String = "buildingName";
      
      protected static const INVALID_VALUE:int = 3735929069;
      
      protected static const BIG_VALUE:Number = 10000000000000000;
      
      protected var m_name:String = null;
      
      protected var m_friendlyName:String = null;
      
      protected var m_code:String = null;
      
      protected var m_limitedStartDate:String = "";
      
      protected var m_limitedEndDate:String = "";
      
      protected var m_limitedStartTime:Number = -559038227;
      
      protected var m_limitedEndTime:Number = -559038227;
      
      protected var m_brandPromoData:BrandPromoData = null;
      
      protected var m_requiredLevel:int = -559038227;
      
      protected var m_limit:Number = -559038227;
      
      protected var m_limitType:String = null;
      
      protected var m_limitPrereq:String = null;
      
      protected var m_cost:int = -559038227;
      
      protected var m_coins:int = -559038227;
      
      protected var m_cash:int = -559038227;
      
      protected var m_xpGained:Number = -559038227;
      
      protected var m_iconUrl:String = null;
      
      protected var m_iconRelativeUrl:String = null;
      
      protected var m_itemXML:XML = null;
      
      protected var m_dataSource:BaseDataSource;
      
      protected var m_imageData:FarmItemImageData = null;
      
      protected var m_brandPromoName:String = null;
      
      protected var m_overrideExportName:String = null;
      
      protected var m_testAssetExportName:String = null;
      
      protected var m_gameSettingsFeatureName:String = null;
      
      private var m_worldToPrefixMap:Object = {};
      
      private var m_worldCurrentlyUsed:String = "";
      
      private var m_imageSetsEnabled:Boolean = false;
      
      private var m_terrainToPrefixMap:Object = {};
      
      public function ZItemBase(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super();
         if(itemXML != null || itemData != null)
         {
            this.onConstruction(itemXML,itemData);
         }
      }
      
      protected function get brandPromoName() : String
      {
         if(this.m_brandPromoName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_brandPromoName = this.m_dataSource.getString("brandPromoName");
            }
            else
            {
               this.m_brandPromoName = this.getXMLProperty(this.m_itemXML,"brandPromoName");
            }
            if(this.m_brandPromoName == "" || this.m_brandPromoName == "false")
            {
               this.m_brandPromoName = null;
            }
         }
         return this.m_brandPromoName;
      }
      
      public function get brandPromoData() : BrandPromoData
      {
         if(Boolean(this.m_brandPromoData == null) && Boolean(this.brandPromoName) && this.brandPromoName != "")
         {
            this.m_brandPromoData = new BrandPromoData(this.brandPromoName,this.name);
         }
         return this.m_brandPromoData;
      }
      
      public function get isBrandedItem() : Boolean
      {
         return this.brandPromoData != null;
      }
      
      public function readExternal(input:IDataInput) : void
      {
         var dataSource:BaseDataSource = input.readObject();
         this.onConstruction(null,dataSource);
      }
      
      public function writeExternal(output:IDataOutput) : void
      {
         output.writeObject(this.m_dataSource);
      }
      
      protected function onConstruction(itemXML:XML, itemData:BaseDataSource) : void
      {
         var imageSetListArr:Array = null;
         var curImageSet:BaseDataSource = null;
         var i:int = 0;
         var terrainArr:Array = null;
         var terrainNameDS:String = null;
         var terrainPrefixDS:String = null;
         var terrainXML:BaseDataSource = null;
         var imageSetList:XMLList = null;
         var index:int = 0;
         var terrainList:XMLList = null;
         var terrain:XML = null;
         var terrainName:String = null;
         var terrainPrefix:String = null;
         this.m_itemXML = itemXML;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
            {
               this.m_dataSource = itemData;
            }
            else if(FarmGameSettingsManager.isInItemsAMFExperiment())
            {
               this.m_dataSource = itemData;
            }
            if(this.m_dataSource == null && Boolean(itemXML))
            {
               this.m_dataSource = new XMLDataSource(itemXML);
            }
            imageSetListArr = this.m_dataSource.getArray("imageSet");
            this.m_worldToPrefixMap[WorldsConstants.WORLD_ID_HOME] = "";
            for(i = 0; i < imageSetListArr.length; i++)
            {
               curImageSet = imageSetListArr[i];
               this.m_worldToPrefixMap[curImageSet.getString("name")] = curImageSet.getString("prefix");
               this.m_imageSetsEnabled = true;
            }
            if(this.m_dataSource.hasProperty("terrainAssets"))
            {
               terrainArr = this.m_dataSource.getArray("terrainAssets","terrain");
               if(terrainArr.length > 0)
               {
                  for each(terrainXML in terrainArr)
                  {
                     terrainNameDS = terrainXML.getString("name");
                     if(terrainXML.hasProperty("prefix"))
                     {
                        terrainPrefixDS = terrainXML.getString("prefix");
                     }
                     else
                     {
                        terrainPrefixDS = terrainNameDS;
                     }
                     this.m_terrainToPrefixMap[terrainNameDS] = terrainPrefixDS;
                  }
               }
            }
         }
         else
         {
            imageSetList = this.m_itemXML.imageSet;
            this.m_worldToPrefixMap[WorldsConstants.WORLD_ID_HOME] = "";
            for(index = 0; index < imageSetList.length(); index++)
            {
               this.m_worldToPrefixMap[imageSetList[index].@name] = imageSetList[index].@prefix;
               this.m_imageSetsEnabled = true;
            }
            if(this.m_itemXML.hasOwnProperty("terrainAssets"))
            {
               terrainList = this.m_itemXML.terrainAssets.terrain;
               if(terrainList.length() > 0)
               {
                  for each(terrain in terrainList)
                  {
                     terrainName = terrain.@name;
                     terrainPrefix = terrain.@prefix;
                     if(terrainPrefix == "")
                     {
                        terrainPrefix = terrainName;
                     }
                     this.m_terrainToPrefixMap[terrainName] = terrainPrefix;
                  }
               }
            }
         }
      }
      
      public function get name() : String
      {
         if(this.m_name == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_name = this.m_dataSource.getString("name");
            }
            else
            {
               this.m_name = this.m_itemXML.@name;
            }
         }
         return this.m_name;
      }
      
      public function get friendlyName() : String
      {
         if(this.m_friendlyName == null)
         {
            this.m_friendlyName = "Items:" + this.name + "_friendlyName";
         }
         return this.m_friendlyName;
      }
      
      public function get code() : String
      {
         if(this.m_code == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_code = this.m_dataSource.getString("code");
            }
            else
            {
               this.m_code = this.m_itemXML.@code;
            }
         }
         return this.m_code;
      }
      
      public function get overrideExportName() : String
      {
         var hasPrecommitDataKey:Boolean = false;
         var preCommitDataSource:BaseDataSource = null;
         var preCommitData:XML = null;
         if(this.m_overrideExportName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_overrideExportName = this.m_dataSource.getString("overrideExportName");
               hasPrecommitDataKey = this.m_dataSource.hasProperty(CMS_PRE_COMMIT_DATA_KEY);
               if(Config.DEBUG_MODE && this.m_overrideExportName == "" && !Global.toolMode && hasPrecommitDataKey)
               {
                  preCommitDataSource = this.m_dataSource.getData(CMS_PRE_COMMIT_DATA_KEY);
                  if(preCommitDataSource)
                  {
                     this.m_overrideExportName = preCommitDataSource.getString(SWF_PLACEHOLDER_ASSET_KEY);
                  }
               }
            }
            else
            {
               this.m_overrideExportName = this.getXMLProperty(this.m_itemXML,"overrideExportName");
               if(Config.DEBUG_MODE && this.m_overrideExportName == null && !Global.toolMode && this.m_itemXML.hasOwnProperty(CMS_PRE_COMMIT_DATA_KEY))
               {
                  preCommitData = this.m_itemXML[CMS_PRE_COMMIT_DATA_KEY][0];
                  this.m_overrideExportName = this.getXMLProperty(preCommitData,SWF_PLACEHOLDER_ASSET_KEY);
               }
            }
            if(this.m_overrideExportName == null)
            {
               this.m_overrideExportName = "";
            }
         }
         return this.m_overrideExportName;
      }
      
      public function set testAssetExportName(export:String) : void
      {
         this.m_testAssetExportName = export;
      }
      
      public function get testAssetExportName() : String
      {
         return this.m_testAssetExportName;
      }
      
      public function getExpectedExportNames() : Array
      {
         var url:String = null;
         var imageArr:Array = null;
         var childDS:BaseDataSource = null;
         var child:XML = null;
         var exports:Array = new Array();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            imageArr = this.m_dataSource.getArray("image");
            for each(childDS in imageArr)
            {
               url = childDS.getString("url");
               if(FarmGameUtil.isStringSWFUrl(url))
               {
                  exports.push(childDS.getString("name"));
               }
            }
         }
         else
         {
            for each(child in this.m_itemXML.child("image"))
            {
               url = child.attribute("url");
               if(FarmGameUtil.isStringSWFUrl(url))
               {
                  exports.push(child.attribute("name"));
               }
            }
         }
         return exports;
      }
      
      public function get gameSettingsFeatureName() : String
      {
         if(this.m_gameSettingsFeatureName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_gameSettingsFeatureName = this.getDataProperty(this.m_dataSource,"gameSettingsFeatureName");
            }
            else
            {
               this.m_gameSettingsFeatureName = this.getXMLProperty(this.m_itemXML,"gameSettingsFeatureName");
            }
            if(this.m_gameSettingsFeatureName == null)
            {
               this.m_gameSettingsFeatureName = UGCDecoManager.DEFAULT_FEATURE_NAME;
            }
         }
         return this.m_gameSettingsFeatureName;
      }
      
      public function getXMLProperty(xml:XML, propName:String) : String
      {
         var param:String = null;
         if(Boolean(xml) && xml.hasOwnProperty(propName))
         {
            param = xml[propName];
         }
         return param;
      }
      
      protected function getDataProperty(dataSource:BaseDataSource, propName:String) : String
      {
         var propValue:String = null;
         if(Boolean(dataSource) && dataSource.hasProperty(propName))
         {
            propValue = dataSource.getString(propName);
         }
         return propValue;
      }
      
      public function getXMLPropertyAsInt(xml:XML, propName:String) : int
      {
         var val:int = 0;
         var valStr:String = this.getXMLProperty(xml,propName);
         if(valStr)
         {
            val = int(valStr);
         }
         else
         {
            val = 0;
         }
         return val;
      }
      
      public function getArrayFromDataSource(... dataHierarchy) : Array
      {
         return this.m_dataSource.getArray.apply(null,dataHierarchy);
      }
      
      public function getStringAtIndexFromDataSource(key:String, idx:int, ... dataHierarchy) : String
      {
         var retStr:String = null;
         var retArr:Array = this.m_dataSource.getData.apply(null,dataHierarchy);
         if(retArr[idx])
         {
            retStr = (retArr[idx] as BaseDataSource).getString(key);
         }
         return retStr;
      }
      
      public function hasPropertyInDataSource(... dataHierarchy) : Boolean
      {
         return this.m_dataSource.hasData.apply(null,dataHierarchy);
      }
      
      public function getNumberFromDataSource(... dataHierarchy) : Number
      {
         return Number(this.m_dataSource.getNumber.apply(null,dataHierarchy));
      }
      
      public function getIntFromDataSource(... dataHierarchy) : int
      {
         return int(this.m_dataSource.getInt.apply(null,dataHierarchy));
      }
      
      public function getBoolFromDataSource(... dataHierarchy) : Boolean
      {
         return Boolean(this.m_dataSource.getBoolean.apply(null,dataHierarchy));
      }
      
      public function getStringFromDataSource(... dataHierarchy) : String
      {
         return this.m_dataSource.getString.apply(null,dataHierarchy);
      }
      
      public function getStringFromDataSourceArray(nameKey:String, nameValue:String, propertyName:String, ... dataHierarchy) : String
      {
         var curDS:BaseDataSource = null;
         var i:int = 0;
         var curStr:String = null;
         var retVal:String = "";
         var arr:* = this.m_dataSource.getArray.apply(null,dataHierarchy);
         var arrLen:int = int(arr.length);
         if(arrLen > 0)
         {
            for(i = 0; i < arrLen; i++)
            {
               curDS = arr[i];
               if(curDS.hasProperty(nameKey))
               {
                  curStr = curDS.getString(nameKey);
                  if(curStr == nameValue)
                  {
                     retVal = curDS.getString(propertyName);
                     break;
                  }
               }
            }
         }
         return retVal;
      }
      
      public function get limitedStartDate() : String
      {
         if(this.m_limitedStartDate == "")
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_limitedStartDate = this.m_dataSource.getString("limitedStart");
            }
            else
            {
               this.m_limitedStartDate = this.getXMLProperty(this.m_itemXML,"limitedStart");
            }
            if(this.m_limitedStartDate == "")
            {
               this.m_limitedStartDate = null;
            }
         }
         return this.m_limitedStartDate;
      }
      
      public function get limitedEndDate() : String
      {
         if(this.m_limitedEndDate == "")
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_limitedEndDate = this.m_dataSource.getString("limitedEnd");
            }
            else
            {
               this.m_limitedEndDate = this.getXMLProperty(this.m_itemXML,"limitedEnd");
            }
            if(this.m_limitedEndDate == "")
            {
               this.m_limitedEndDate = null;
            }
         }
         return this.m_limitedEndDate;
      }
      
      public function get limitedStartTime() : Number
      {
         if(GlobalEngine.isServerTimeValid() && this.m_limitedStartTime == INVALID_VALUE)
         {
            this.m_limitedStartTime = FarmGameUtil.synchronizedDateToNumber(this.limitedStartDate);
         }
         return this.m_limitedStartTime;
      }
      
      public function get limitedEndTime() : Number
      {
         if(GlobalEngine.isServerTimeValid() && this.m_limitedEndTime == INVALID_VALUE)
         {
            this.m_limitedEndTime = FarmGameUtil.synchronizedDateToNumber(this.limitedEndDate);
         }
         return this.m_limitedEndTime;
      }
      
      public function get limitedTimeLeft() : Number
      {
         return this.limitedEndTime - GlobalEngine.serverTime;
      }
      
      public function get timeSinceStarted() : Number
      {
         return GlobalEngine.serverTime - this.limitedStartTime;
      }
      
      public function get isLimited() : Boolean
      {
         return Boolean(this.limitedStartDate) && Boolean(this.limitedEndDate);
      }
      
      public function checkDateGate() : Boolean
      {
         var returnVal:Boolean = true;
         if(this.isLimited)
         {
            returnVal = !(this.limitedStartTime > GlobalEngine.serverTime || this.limitedEndTime < GlobalEngine.serverTime);
         }
         return returnVal;
      }
      
      public function get requiredLevel() : int
      {
         var level:String = null;
         if(this.m_requiredLevel == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_requiredLevel = this.m_dataSource.getInt("requiredLevel");
            }
            else
            {
               level = this.getXMLProperty(this.m_itemXML,"requiredLevel");
               if(level)
               {
                  this.m_requiredLevel = int(level);
               }
               else
               {
                  this.m_requiredLevel = 0;
               }
            }
         }
         return this.m_requiredLevel;
      }
      
      public function get limit() : Number
      {
         var limitString:String = null;
         if(this.m_limit == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_limit = this.m_dataSource.getNumber("limit");
            }
            else
            {
               limitString = this.getXMLProperty(this.m_itemXML,"limit");
               if(limitString)
               {
                  this.m_limit = Number(limitString);
               }
               else
               {
                  this.m_limit = 0;
               }
            }
         }
         return this.m_limit;
      }
      
      public function get limitType() : String
      {
         if(this.m_limitType == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_limitType = this.m_dataSource.getString("limitType");
            }
            else
            {
               this.m_limitType = this.getXMLProperty(this.m_itemXML,"limitType");
            }
         }
         return this.m_limitType;
      }
      
      public function get limitPrereq() : String
      {
         var limitString:String = null;
         if(this.m_limitPrereq == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_limitPrereq = this.m_dataSource.getString("limitPrereq");
            }
            else
            {
               limitString = this.getXMLProperty(this.m_itemXML,"limitPrereq");
               if(limitString)
               {
                  this.m_limitPrereq = limitString;
               }
               else
               {
                  this.m_limitPrereq = "";
               }
            }
         }
         return this.m_limitPrereq;
      }
      
      public function get cost() : int
      {
         var costString:String = null;
         if(this.m_cost == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_cost = this.m_dataSource.getInt("cost");
            }
            else
            {
               costString = this.getXMLProperty(this.m_itemXML,"cost");
               if(costString)
               {
                  this.m_cost = int(costString);
               }
               else
               {
                  this.m_cost = 0;
               }
            }
         }
         return this.m_cost;
      }
      
      public function get coins() : int
      {
         var coinsString:String = null;
         if(this.m_coins == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               coinsString = this.m_dataSource.getString("coins");
            }
            else
            {
               coinsString = this.getXMLProperty(this.m_itemXML,"coins");
            }
            if(coinsString)
            {
               this.m_coins = int(coinsString);
            }
            else
            {
               this.m_coins = 0;
            }
         }
         return this.m_coins;
      }
      
      public function get cash() : int
      {
         var cashString:String = null;
         if(this.m_cash == INVALID_VALUE)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_cash = this.m_dataSource.getInt("cash");
            }
            else
            {
               cashString = this.getXMLProperty(this.m_itemXML,"cash");
               if(cashString)
               {
                  this.m_cash = int(cashString);
               }
               else
               {
                  this.m_cash = 0;
               }
            }
         }
         return this.m_cash;
      }
      
      public function get xpGained() : Number
      {
         var buyXp:String = null;
         if(this.m_xpGained == INVALID_VALUE)
         {
            this.m_xpGained = Math.floor(this.cost * Global.farmGameSettingsManager.getNumber("buyXpGainRatio"));
         }
         if(this.m_xpGained != 0)
         {
            this.m_xpGained = Math.max(this.m_xpGained,Global.farmGameSettingsManager.getNumber("buyXpGainMin"));
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            buyXp = this.getDataProperty(this.m_dataSource,"buyXp");
         }
         else
         {
            buyXp = this.getXMLProperty(this.m_itemXML,"buyXp");
         }
         if(buyXp != null && !isNaN(Number(buyXp)))
         {
            this.m_xpGained = Number(buyXp);
         }
         return this.m_xpGained;
      }
      
      public function mapImageName(imageName:String) : String
      {
         var currentWorldType:String = Global.worldManager.currentWorldType;
         if(this.m_worldToPrefixMap.hasOwnProperty(currentWorldType) && "" != this.m_worldToPrefixMap[currentWorldType])
         {
            imageName = this.m_worldToPrefixMap[currentWorldType] + imageName;
         }
         return imageName;
      }
      
      private function createImageObject(imageUrl:String, index:int, terrain:String, pattern:String, substitution:String = null) : Object
      {
         var rawImageArr:Array = null;
         var rawImageDS:BaseDataSource = null;
         var imageName:String = null;
         var rawImage:XML = null;
         var image:Object = {};
         if(terrain != "")
         {
            terrain += "_";
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            rawImageArr = this.m_dataSource.getArray("image");
            rawImageDS = rawImageArr[index];
            imageName = rawImageDS.getString("name");
            if(pattern == "" || !substitution)
            {
               image.url = Global.getAssetURL(imageUrl);
               image.name = terrain + imageName;
            }
            else
            {
               image.url = Global.getAssetURL(imageUrl.replace(substitution,pattern));
               image.name = terrain + pattern + "_" + imageName;
            }
            image.loadClass = rawImageDS.getString("loadClass");
            if(rawImageDS.hasProperty("trackAnimation"))
            {
               image.trackAnimation = rawImageDS.getString("trackAnimation");
            }
            if(rawImageDS.hasProperty("pixelPerfectPick"))
            {
               image.pixelPerfectPick = rawImageDS.getString("pixelPerfectPick");
            }
            image.prefix = null;
            if(rawImageDS.hasProperty("prefix"))
            {
               image.prefix = rawImageDS.getString("prefix");
            }
            image.label = null;
            if(rawImageDS.hasProperty("label"))
            {
               image.label = rawImageDS.getString("label");
            }
            if(rawImageDS.hasProperty("lowResBitmapFrame"))
            {
               image.lowResBitmapFrame = rawImageDS.getInt("lowResBitmapFrame");
            }
         }
         else
         {
            rawImage = this.m_itemXML.image[index];
            if(pattern == "" || !substitution)
            {
               image.url = Global.getAssetURL(imageUrl);
               image.name = terrain + rawImage[XMLKeys.ATTR_NAME];
            }
            else
            {
               image.url = Global.getAssetURL(imageUrl.replace(substitution,pattern));
               image.name = terrain + pattern + "_" + rawImage[XMLKeys.ATTR_NAME];
            }
            image.loadClass = rawImage[XMLKeys.ATTR_LOAD_CLASS].toString();
            if(rawImage.hasOwnProperty(XMLKeys.ATTR_TRACK_ANIMATION) && rawImage[XMLKeys.ATTR_TRACK_ANIMATION].toString() != "")
            {
               image.trackAnimation = rawImage[XMLKeys.ATTR_TRACK_ANIMATION].toString();
            }
            if(rawImage.hasOwnProperty(XMLKeys.ATTR_PIXEL_PERFECT_PICK_CLASS) && rawImage[XMLKeys.ATTR_PIXEL_PERFECT_PICK_CLASS].toString() != "")
            {
               image.pixelPerfectPick = rawImage[XMLKeys.ATTR_PIXEL_PERFECT_PICK_CLASS];
            }
            image.prefix = null;
            if(rawImage.hasOwnProperty(XMLKeys.ATTR_PREFIX) && rawImage[XMLKeys.ATTR_PREFIX].toString() != "")
            {
               image.prefix = rawImage[XMLKeys.ATTR_PREFIX].toString();
            }
            image.label = null;
            if(rawImage.hasOwnProperty(XMLKeys.ATTR_LABEL) && rawImage[XMLKeys.ATTR_LABEL].toString() != "")
            {
               image.label = rawImage[XMLKeys.ATTR_LABEL].toString();
            }
            if(rawImage.hasOwnProperty(XMLKeys.ATTR_LOW_RES_BITMAP_FRAME) && rawImage[XMLKeys.ATTR_LOW_RES_BITMAP_FRAME].toString() != "")
            {
               image.lowResBitmapFrame = parseInt(rawImage[XMLKeys.ATTR_LOW_RES_BITMAP_FRAME].toString());
            }
         }
         image.rasterMetaDataUrl = null;
         if(PerformanceExperimentManager.isInRasterMetadataExperiment)
         {
            index = int(image.url.lastIndexOf(".swf"));
            if(index >= 0)
            {
               image.rasterMetaDataUrl = "true";
            }
         }
         return image;
      }
      
      public function getDataSource() : BaseDataSource
      {
         if(FarmGameSettingsManager.isInDataSourceExperiment() && Boolean(this.m_dataSource))
         {
            return this.m_dataSource;
         }
         return null;
      }
      
      public function getImageData() : FarmItemImageData
      {
         var patternArray:Array = null;
         var substitution:String = null;
         var images:Array = null;
         var imageUrl:String = null;
         var terrainArray:Array = null;
         var terrName:String = null;
         var multipleBuildableExpProp:String = null;
         var isItemInMultipleBuildableSwfsExp:Boolean = false;
         var isInMultipleBuildableSwfsExp:Boolean = false;
         var imageArr:Array = null;
         var imageHasMultipleBuildableProp:Boolean = false;
         var curImageDataSource:BaseDataSource = null;
         var imgIndex:int = 0;
         var imageScale:Number = NaN;
         var dontUseAnimation:Boolean = false;
         var patternStr:String = null;
         var terrainIdx:int = 0;
         var patternIdx:int = 0;
         var terrainName:String = null;
         var multipleBuildableExperimentProperty:String = null;
         var isItemInMultipleBuildableSwfsExperiment:Boolean = false;
         var isInMultipleBuildableSwfsExperiment:Boolean = false;
         var imgIdx:int = 0;
         var patternString:String = null;
         var j:int = 0;
         var i:int = 0;
         if(this.m_imageData == null)
         {
            patternArray = [];
            substitution = null;
            images = [];
            terrainArray = [];
            this.m_imageData = new FarmItemImageData();
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               if(this.m_dataSource.hasProperty("imageScale"))
               {
                  imageScale = this.m_dataSource.getNumber("imageScale");
                  if(imageScale > 0)
                  {
                     this.m_imageData.imageScale = imageScale;
                  }
               }
               if(this.m_dataSource.hasProperty("dontUseAnimation"))
               {
                  dontUseAnimation = this.m_dataSource.getBoolean("dontUseAnimation");
                  if(dontUseAnimation)
                  {
                     this.m_imageData.canUseAnimation = false;
                  }
               }
               if(this.m_dataSource.hasProperty("patterns") && this.m_dataSource.hasProperty("substitution_string"))
               {
                  patternStr = this.m_dataSource.getString("patterns");
                  patternArray = patternStr.split(",");
                  substitution = this.m_dataSource.getString("substitution_string");
               }
               terrainArray.push("");
               for(terrName in this.m_terrainToPrefixMap)
               {
                  terrainArray.push(this.m_terrainToPrefixMap[terrName]);
               }
               multipleBuildableExpProp = Experiments.EXPERIMENT_FLASH_PERF_MULTIPLE_BUILDABLES_SWFS;
               isItemInMultipleBuildableSwfsExp = this.m_dataSource.hasProperty(multipleBuildableExpProp);
               isInMultipleBuildableSwfsExp = isItemInMultipleBuildableSwfsExp && PerformanceExperimentManager.isInMultipleBuildableSwfsExperiment;
               imageArr = this.m_dataSource.getArray("image");
               for(imgIndex = 0; imgIndex < imageArr.length; imgIndex++)
               {
                  curImageDataSource = imageArr[imgIndex] as BaseDataSource;
                  imageHasMultipleBuildableProp = curImageDataSource.hasProperty(multipleBuildableExpProp);
                  if(!(isInMultipleBuildableSwfsExp && !imageHasMultipleBuildableProp || !isInMultipleBuildableSwfsExp && isItemInMultipleBuildableSwfsExp && imageHasMultipleBuildableProp))
                  {
                     imageUrl = curImageDataSource.getString("url");
                     for(terrainIdx = 0; terrainIdx < terrainArray.length; terrainIdx++)
                     {
                        if(!substitution || imageUrl.search(substitution) <= 0)
                        {
                           images.push(this.createImageObject(imageUrl,imgIndex,terrainArray[terrainIdx],"",null));
                        }
                        else
                        {
                           for(patternIdx = 0; patternIdx < patternArray.length; patternIdx++)
                           {
                              images.push(this.createImageObject(imageUrl,imgIndex,terrainArray[terrainIdx],patternArray[patternIdx],substitution));
                           }
                        }
                     }
                  }
               }
            }
            else
            {
               if(this.m_itemXML.hasOwnProperty("imageScale") && Number(this.m_itemXML.imageScale) > 0)
               {
                  this.m_imageData.imageScale = Number(this.m_itemXML.imageScale);
               }
               if(this.m_itemXML.hasOwnProperty("@dontUseAnimation") && this.m_itemXML.@dontUseAnimation == "true")
               {
                  this.m_imageData.canUseAnimation = false;
               }
               if(this.m_itemXML.hasOwnProperty("patterns") && this.m_itemXML.hasOwnProperty("substitution_string"))
               {
                  patternString = this.m_itemXML.patterns;
                  patternArray = patternString.split(",");
                  substitution = String(this.m_itemXML.substitution_string);
               }
               terrainArray.push("");
               for(terrainName in this.m_terrainToPrefixMap)
               {
                  terrainArray.push(this.m_terrainToPrefixMap[terrainName]);
               }
               multipleBuildableExperimentProperty = "@" + Experiments.EXPERIMENT_FLASH_PERF_MULTIPLE_BUILDABLES_SWFS;
               isItemInMultipleBuildableSwfsExperiment = this.m_itemXML.hasOwnProperty(multipleBuildableExperimentProperty);
               isInMultipleBuildableSwfsExperiment = isItemInMultipleBuildableSwfsExperiment && PerformanceExperimentManager.isInMultipleBuildableSwfsExperiment;
               for(imgIdx = 0; imgIdx < this.m_itemXML.image.length(); imgIdx++)
               {
                  if(!(isInMultipleBuildableSwfsExperiment && !this.m_itemXML.image[imgIdx].hasOwnProperty(multipleBuildableExperimentProperty) || Boolean(!isInMultipleBuildableSwfsExperiment && isItemInMultipleBuildableSwfsExperiment) && Boolean(this.m_itemXML.image[imgIdx].hasOwnProperty(multipleBuildableExperimentProperty))))
                  {
                     imageUrl = this.m_itemXML.image[imgIdx].@url;
                     for(j = 0; j < terrainArray.length; j++)
                     {
                        if(!substitution || imageUrl.search(substitution) <= 0)
                        {
                           images.push(this.createImageObject(imageUrl,imgIdx,terrainArray[j],"",null));
                        }
                        else
                        {
                           for(i = 0; i < patternArray.length; i++)
                           {
                              images.push(this.createImageObject(imageUrl,imgIdx,terrainArray[j],patternArray[i],substitution));
                           }
                        }
                     }
                  }
               }
            }
            this.m_imageData.images = images;
         }
         return this.m_imageData;
      }
      
      private function clearStaleUrls() : void
      {
         if(this.m_imageSetsEnabled && Global.worldManager.currentWorldType != this.m_worldCurrentlyUsed)
         {
            this.m_worldCurrentlyUsed = Global.worldManager.currentWorldType;
            this.m_iconUrl = null;
            this.m_iconRelativeUrl = null;
         }
      }
      
      public function get iconUrl() : String
      {
         this.clearStaleUrls();
         if(null == this.m_iconUrl)
         {
            this.m_iconUrl = Global.getAssetURL(this.iconRelativeUrl);
         }
         return this.m_iconUrl;
      }
      
      public function get iconRelativeUrl() : String
      {
         this.clearStaleUrls();
         if(this.m_iconRelativeUrl == null)
         {
            this.m_iconRelativeUrl = this.imageRelativeUrl(this.mapImageName("icon"));
         }
         return this.m_iconRelativeUrl;
      }
      
      public function imageRelativeUrl(imageName:String) : String
      {
         var imageArr:Array = null;
         var imgCount:int = 0;
         var curImage:BaseDataSource = null;
         var i:int = 0;
         var images:XMLList = null;
         var result:String = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            imageArr = this.m_dataSource.getArray("image");
            imgCount = int(imageArr.length);
            for(i = 0; i < imgCount; i++)
            {
               curImage = imageArr[i];
               if(curImage.getString("name") == imageName)
               {
                  result = curImage.getString("url");
                  break;
               }
            }
         }
         else
         {
            images = this.m_itemXML.image.(@name == imageName);
            if(images.length())
            {
               result = images[0].@url;
            }
         }
         return result;
      }
      
      public function masteryIconUrl(absUrl:Boolean = true, level:int = 0) : String
      {
         var levelKey:String = MASTERY_ICON_KEY + "_Level_" + level.toString();
         var result:String = null;
         if(level > 0)
         {
            result = this.imageRelativeUrl(levelKey);
         }
         if(result == null)
         {
            result = this.imageRelativeUrl(MASTERY_ICON_KEY);
         }
         if(result != null && absUrl)
         {
            result = Global.getAssetURL(result);
         }
         return result;
      }
      
      public function flush() : void
      {
         this.m_cost = INVALID_VALUE;
         this.m_coins = INVALID_VALUE;
         this.m_cash = INVALID_VALUE;
         this.m_xpGained = INVALID_VALUE;
      }
      
      public function getTerrainPrefix(terrainName:String, separator:String = "_") : String
      {
         var terrainPrefix:String = "";
         if(this.m_terrainToPrefixMap.hasOwnProperty(terrainName))
         {
            terrainPrefix = this.m_terrainToPrefixMap[terrainName] + separator;
         }
         return terrainPrefix;
      }
   }
}

