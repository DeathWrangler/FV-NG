package Classes.AreasOfEffect
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   import flash.geom.Rectangle;
   
   public class AOEConfig
   {
      
      public static const BONUS_VISUALCHANGE:String = "visualChange";
      
      private var m_arrAreas:Vector.<Rectangle>;
      
      private var m_arrBonusMultipliers:Array;
      
      private var m_arrBonusCumulative:Array;
      
      private var m_arrTargetClasses:Array;
      
      private var m_stateChange:String;
      
      private var m_aoeHighlightColor:uint;
      
      private var m_aoeHighlightColorActive:Boolean;
      
      private var m_arrTargetTypes:Array;
      
      private var m_arrTargetKeywords:Array;
      
      private var m_targetsSelf:Boolean = false;
      
      private var m_targetItemCodes:Array;
      
      private var m_targetItemCodeMap:Object;
      
      private var m_itemCode:String;
      
      private var m_showTargetBonusOnSourceMouseMove:Boolean = true;
      
      private var m_consolidateBonusOnSourceMove:Boolean = false;
      
      private var m_locKey:String;
      
      public function AOEConfig(code:String, aoeXml:XMLList, aoeData:BaseDataSource = null)
      {
         var bonusType:String = null;
         var bonusValue:Number = NaN;
         var type:String = null;
         var value:String = null;
         var bonusesArray:Array = null;
         var targetsArray:Array = null;
         var areasArray:Array = null;
         var bonusData:BaseDataSource = null;
         var targetData:BaseDataSource = null;
         var areaData:BaseDataSource = null;
         var bonusesXml:XMLList = null;
         var targetsXml:XMLList = null;
         var areasXml:XMLList = null;
         var bonusXml:XML = null;
         var targetXml:XML = null;
         var areaXml:XML = null;
         super();
         this.m_arrBonusMultipliers = new Array();
         this.m_arrBonusCumulative = new Array();
         this.m_arrAreas = new Vector.<Rectangle>();
         this.m_arrTargetClasses = new Array();
         this.m_arrTargetTypes = new Array();
         this.m_arrTargetKeywords = new Array();
         this.m_stateChange = null;
         this.m_itemCode = code;
         if(aoeData)
         {
            this.m_showTargetBonusOnSourceMouseMove = !aoeData.hasProperty("showTargetBonusOnSourceMouseOver") || aoeData.getBoolean("showTargetBonusOnSourceMouseOver");
            this.m_consolidateBonusOnSourceMove = aoeData.getBoolean("consolidateBonusOnSourceMove");
            this.m_locKey = aoeData.getString("locKey");
            bonusesArray = aoeData.getArray("bonuses","bonus");
            if(bonusesArray.length > 0)
            {
               for each(bonusData in bonusesArray)
               {
                  if(bonusData.hasProperty("type") && bonusData.hasProperty("value"))
                  {
                     bonusType = bonusData.getString("type");
                     if(bonusType === AOEConfig.BONUS_VISUALCHANGE)
                     {
                        this.m_stateChange = bonusData.getString("value");
                        this.m_aoeHighlightColor = bonusData.getNumber("highlightColor");
                     }
                     else
                     {
                        bonusValue = bonusData.getNumber("value");
                        if(bonusData.hasProperty("op") && bonusData.getString("op") == "add")
                        {
                           this.m_arrBonusCumulative[bonusType] = bonusValue;
                        }
                        else
                        {
                           this.m_arrBonusMultipliers[bonusType] = bonusValue;
                        }
                     }
                  }
               }
            }
            targetsArray = aoeData.getArray("targets","target");
            if(targetsArray.length > 0)
            {
               for each(targetData in targetsArray)
               {
                  if(targetData.hasProperty("type"))
                  {
                     type = targetData.getString("type");
                  }
                  if(targetData.hasProperty("value"))
                  {
                     value = targetData.getString("value");
                  }
                  if(type == "class")
                  {
                     this.m_arrTargetClasses[value] = true;
                  }
                  else if(type == "self")
                  {
                     this.m_targetsSelf = true;
                  }
                  else if(type == "type")
                  {
                     this.m_arrTargetTypes[value] = true;
                  }
                  else if(type == "keyword")
                  {
                     this.m_arrTargetKeywords[value] = true;
                  }
               }
            }
            areasArray = aoeData.getArray("areas","area");
            if(areasArray.length > 0)
            {
               for each(areaData in areasArray)
               {
                  this.m_arrAreas.push(new Rectangle(areaData.getInt("x"),areaData.getInt("y"),areaData.getInt("width"),areaData.getInt("height")));
               }
            }
         }
         else if(aoeXml != null)
         {
            this.m_showTargetBonusOnSourceMouseMove = !(aoeXml.hasOwnProperty("@showTargetBonusOnSourceMouseOver") && aoeXml.@showTargetBonusOnSourceMouseOver.toString() == "false");
            this.m_consolidateBonusOnSourceMove = aoeXml.hasOwnProperty("@consolidateBonusOnSourceMove") && aoeXml.@consolidateBonusOnSourceMove.toString() == "true";
            this.m_locKey = aoeXml.hasOwnProperty("@locKey") ? aoeXml.@locKey.toString() : "";
            bonusesXml = aoeXml.bonuses.bonus;
            if(bonusesXml != null)
            {
               for each(bonusXml in bonusesXml)
               {
                  if(bonusXml.hasOwnProperty("@type") && bonusXml.hasOwnProperty("@value"))
                  {
                     bonusType = String(bonusXml.@type);
                     if(bonusType === AOEConfig.BONUS_VISUALCHANGE)
                     {
                        this.m_stateChange = String(bonusXml.@value);
                        this.m_aoeHighlightColor = bonusXml.@highlightColor;
                     }
                     else
                     {
                        bonusValue = Number(bonusXml.@value);
                        if(bonusXml.hasOwnProperty("@op") && String(bonusXml.@op) == "add")
                        {
                           this.m_arrBonusCumulative[bonusType] = bonusValue;
                        }
                        else
                        {
                           this.m_arrBonusMultipliers[bonusType] = bonusValue;
                        }
                     }
                  }
               }
            }
            targetsXml = aoeXml.targets.target;
            if(targetsXml != null)
            {
               for each(targetXml in targetsXml)
               {
                  if(targetXml.hasOwnProperty("@type"))
                  {
                     type = String(targetXml.@type);
                  }
                  if(targetXml.hasOwnProperty("@value"))
                  {
                     value = String(targetXml.@value);
                  }
                  if(type == "class")
                  {
                     this.m_arrTargetClasses[value] = true;
                  }
                  else if(type == "self")
                  {
                     this.m_targetsSelf = true;
                  }
                  else if(type == "type")
                  {
                     this.m_arrTargetTypes[value] = true;
                  }
                  else if(type == "keyword")
                  {
                     this.m_arrTargetKeywords[value] = true;
                  }
               }
            }
            areasXml = aoeXml.areas.area;
            if(areasXml != null)
            {
               for each(areaXml in areasXml)
               {
                  this.m_arrAreas.push(new Rectangle(parseInt(areaXml.@x),parseInt(areaXml.@y),parseInt(areaXml.@width),parseInt(areaXml.@height)));
               }
            }
         }
      }
      
      public function get areas() : Vector.<Rectangle>
      {
         return this.m_arrAreas;
      }
      
      public function get bonusMultipliers() : Array
      {
         return this.m_arrBonusMultipliers;
      }
      
      public function get bonusCumulative() : Array
      {
         return this.m_arrBonusCumulative;
      }
      
      public function get highlightColor() : uint
      {
         return this.m_aoeHighlightColor;
      }
      
      public function set highlightColor(color:uint) : void
      {
         this.m_aoeHighlightColor = color;
      }
      
      public function get highlightColorActive() : Boolean
      {
         return this.m_aoeHighlightColorActive;
      }
      
      public function set highlightColorActive(isActive:Boolean) : void
      {
         this.m_aoeHighlightColorActive = isActive;
      }
      
      public function get stateChange() : String
      {
         return this.m_stateChange;
      }
      
      public function get itemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function getTargetItemCodes() : Array
      {
         if(!this.m_targetItemCodes)
         {
            this.buildTargetList();
         }
         return this.m_targetItemCodes;
      }
      
      public function targets(targetResource:MapResource) : Boolean
      {
         var code:String = null;
         var result:Boolean = false;
         var className:String = targetResource.getClassName();
         if(className != "" && this.m_arrTargetClasses[className] != null)
         {
            result = true;
         }
         else if(targetResource.getItem())
         {
            if(!this.m_targetItemCodeMap)
            {
               this.buildTargetList();
            }
            code = targetResource.getItem().code;
            if(code != "")
            {
               result = this.m_targetItemCodeMap[code] == 1;
               if(targetResource.getItem().type == "seed")
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function get targetsSelf() : Boolean
      {
         return this.m_targetsSelf;
      }
      
      private function buildTargetList() : void
      {
         var farmItem:FarmItem = null;
         var items:Array = null;
         var className:String = null;
         var type:String = null;
         var keyword:String = null;
         var itemCode:String = null;
         var itemCodeMap:Object = new Object();
         for(className in this.m_arrTargetClasses)
         {
            items = Global.farmGameSettingsManager.getItemsByClassArray(className);
            for each(farmItem in items)
            {
               itemCodeMap[farmItem.code] = 1;
            }
         }
         for(type in this.m_arrTargetTypes)
         {
            items = Global.farmGameSettingsManager.getFarmItemsArrayByType(type);
            for each(farmItem in items)
            {
               itemCodeMap[farmItem.code] = 1;
            }
         }
         for(keyword in this.m_arrTargetKeywords)
         {
            items = Global.farmGameSettingsManager.getItemsByAoeTargetKeyword(keyword);
            for each(farmItem in items)
            {
               itemCodeMap[farmItem.code] = 1;
            }
         }
         this.m_targetItemCodeMap = itemCodeMap;
         this.m_targetItemCodes = new Array();
         for(itemCode in itemCodeMap)
         {
            this.m_targetItemCodes.push(itemCode);
         }
      }
      
      public function get showTargetBonusOnSourceMouseMove() : Boolean
      {
         return this.m_showTargetBonusOnSourceMouseMove;
      }
      
      public function get consolidateBonusOnSourceMove() : Boolean
      {
         return this.m_consolidateBonusOnSourceMove;
      }
      
      public function get locKey() : String
      {
         return this.m_locKey;
      }
   }
}

