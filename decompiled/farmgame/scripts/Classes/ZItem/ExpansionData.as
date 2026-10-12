package Classes.ZItem
{
   import Classes.FarmingAttributes;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Widgets.Constants.Market.Currency;
   
   public class ExpansionData
   {
      
      private static const ATTR_NAME:String = "@name";
      
      private static const ATTR_SEASON:String = "@season";
      
      private static const ATTR_CURRENCY:String = "@currency";
      
      private static const ATTR_SCORE:String = "@score";
      
      private static const ATTR_SCORE2:String = "@score2";
      
      private static const ATTR_SCOREFILE:String = "@scoreFile";
      
      private static const ATTR_PLOTS:String = "@plots";
      
      private static const ATTR_SQUARES:String = "@squares";
      
      private static const ATTR_MAX:String = "@max";
      
      private static const NODE_WORLD_REQUIREMENT_OVERRIDE:String = "worldRequirementOverride";
      
      private static const NODE_SHOW_IN_TRAVEL_DIALOG:String = "showInTravelDialog";
      
      private static const NODE_STATIC_WORLD:String = "staticWorld";
      
      private static const NODE_FARMING:String = "farming";
      
      private static const ATTR_TYPE:String = "@type";
      
      private static const ATTR_ID:String = "@id";
      
      private static const ATTR_EA:String = "@earlyAccess";
      
      private static const ATTR_GA:String = "@generalAccess";
      
      private static const ATTR_UNLOCK:String = "@unlockDialog";
      
      private static const ATTR_SEASON_DIALOG:String = "@dialog";
      
      private static const ATTR_ASSET:String = "@asset";
      
      private static const ATTR_WINDOWCLASS:String = "@windowClass";
      
      private static const ATTR_FTUE_URL:String = "@ftueUrl";
      
      private static const NODE_FRIENDLY_NAME:String = "friendlyName";
      
      private static const NODE_FRIEND_SET_CODE:String = "friendSetCode";
      
      private static const NODE_HUD_ICON:String = "hudIcon";
      
      private static const NODE_MORE_INFO_DIALOG:String = "moreInfoDialog";
      
      private static const NODE_PLOT_LIMITS:String = "plotLimits";
      
      private static const NODE_MOTDS:String = "motds";
      
      private static const NODE_SEASONS:String = "seasons";
      
      public static const NODE_SUPER_BUILDINGS:String = "superBuildings";
      
      private static const NODE_EARLY_ACCESS_GIFTING:String = "earlyAccessGifting";
      
      private static const NODE_SHIPPING_LICENSE_ITEM_NAME:String = "shippingLicenseItemName";
      
      private static const NODE_BUSHEL_CHANCE_SCALE:String = "bushelChanceScale";
      
      public static const KEY_WINDOWCLASS:String = "windowClass";
      
      public static const KEY_ASSET:String = "assetPath";
      
      public static const KEY_FTUE:String = "ftuePath";
      
      public static const KEY_SEASON:String = "season";
      
      public static const NODE_PREREQS:String = "prereqs";
      
      public static const KEY_SEASON_ID:String = "id";
      
      public static const KEY_SEASON_NAME:String = "name";
      
      public static const KEY_NAME:String = "name";
      
      public static const KEY_MAX:String = "max";
      
      public static const KEY_SEASON_DIALOG:String = "dialog";
      
      public static const KEY_SEASON_EA:String = "earlyAccess";
      
      public static const KEY_SEASON_GA:String = "generalAccess";
      
      public static const KEY_SEASON_UNLOCK:String = "unlockDialog";
      
      private var m_farmingAttributes:FarmingAttributes;
      
      private var m_name:String;
      
      private var m_season:int;
      
      private var m_currency:String;
      
      private var m_scoreId:String = null;
      
      private var m_score2Id:String = null;
      
      private var m_scoreFile:String = null;
      
      private var m_friendlyNameKey:String;
      
      private var m_friendSetCode:String;
      
      private var m_hudIcon:String;
      
      private var m_moreInfoDialog:String;
      
      private var m_plotLimits:ExpansionPlotLimits = null;
      
      private var m_motds:Object;
      
      private var m_shippingLicenseItemName:String = null;
      
      private var m_bushelChanceScale:Number = 1;
      
      private var m_accessTypes:Object;
      
      private var m_showInTravelDialog:Boolean = true;
      
      private var m_staticWorld:Boolean = false;
      
      private var m_prereqs:Array;
      
      private var m_worldRequirementOverride:String;
      
      private var m_earlyAccessGifting:ExpansionEarlyAccessGiftingData;
      
      private var m_seasons:Object;
      
      private var m_superBuildings:Object = null;
      
      public function ExpansionData(xml:XML)
      {
         var children:XMLList = null;
         var childXML:XML = null;
         var accessInfo:ExpansionAccess = null;
         var motdXML:XML = null;
         var motdObject:Object = null;
         var superBuildingXML:XML = null;
         var buildingId:String = null;
         var buildingObject:Object = null;
         var seasonXML:XML = null;
         var seasonObject:Object = null;
         var dialogObject:Object = null;
         var dialogXML:XML = null;
         this.m_prereqs = new Array();
         super();
         if(xml)
         {
            if(xml.hasOwnProperty(ATTR_NAME))
            {
               this.m_name = xml[ATTR_NAME];
               this.m_worldRequirementOverride = this.m_name;
            }
            if(xml.hasOwnProperty(ATTR_SEASON))
            {
               this.m_season = xml[ATTR_SEASON];
            }
            else
            {
               this.m_season = 1;
            }
            if(xml.hasOwnProperty(ATTR_CURRENCY))
            {
               this.m_currency = xml[ATTR_CURRENCY];
            }
            else
            {
               this.m_currency = Currency.COINS;
            }
            if(xml.hasOwnProperty(ATTR_SCORE))
            {
               this.m_scoreId = xml[ATTR_SCORE];
            }
            if(xml.hasOwnProperty(ATTR_SCORE2))
            {
               this.m_score2Id = xml[ATTR_SCORE2];
            }
            if(xml.hasOwnProperty(ATTR_SCOREFILE))
            {
               this.m_scoreFile = xml[ATTR_SCOREFILE];
            }
            this.m_farmingAttributes = new FarmingAttributes();
            this.m_accessTypes = new Object();
            this.m_plotLimits = null;
            children = xml.children();
            for each(childXML in children)
            {
               if(ExpansionAccess.isAccessTypeNode(childXML))
               {
                  accessInfo = new ExpansionAccess(childXML);
                  this.m_accessTypes[accessInfo.type] = accessInfo;
                  continue;
               }
               switch(childXML.name().toString())
               {
                  case NODE_FARMING:
                     this.m_farmingAttributes.initWithXml(childXML);
                     break;
                  case NODE_FRIENDLY_NAME:
                     this.m_friendlyNameKey = childXML.toString();
                     break;
                  case NODE_FRIEND_SET_CODE:
                     this.m_friendSetCode = childXML.toString();
                     break;
                  case NODE_HUD_ICON:
                     this.m_hudIcon = childXML.toString();
                     break;
                  case NODE_MORE_INFO_DIALOG:
                     this.m_moreInfoDialog = childXML.toString();
                     break;
                  case NODE_PLOT_LIMITS:
                     this.m_plotLimits = new ExpansionPlotLimits(this.m_name,childXML.children());
                     break;
                  case NODE_MOTDS:
                     this.m_motds = new Object();
                     for each(motdXML in childXML.children())
                     {
                        if(motdXML.hasOwnProperty(ATTR_TYPE))
                        {
                           motdObject = new Object();
                           if(motdXML.hasOwnProperty(ATTR_ASSET))
                           {
                              motdObject[KEY_ASSET] = String(motdXML[ATTR_ASSET]);
                           }
                           if(motdXML.hasOwnProperty(ATTR_WINDOWCLASS))
                           {
                              motdObject[KEY_WINDOWCLASS] = String(motdXML[ATTR_WINDOWCLASS]);
                           }
                           if(motdXML.hasOwnProperty(ATTR_FTUE_URL))
                           {
                              motdObject[KEY_FTUE] = String(motdXML[ATTR_FTUE_URL]);
                           }
                           if(motdXML.hasOwnProperty(ATTR_SEASON))
                           {
                              this.m_motds[String(motdXML[ATTR_TYPE]) + "_" + String(motdXML[ATTR_SEASON])] = motdObject;
                           }
                           else
                           {
                              this.m_motds[String(motdXML[ATTR_TYPE])] = motdObject;
                           }
                        }
                     }
                     break;
                  case NODE_SUPER_BUILDINGS:
                     this.m_superBuildings = new Object();
                     for each(superBuildingXML in childXML.children())
                     {
                        if(superBuildingXML.hasOwnProperty(ATTR_ID))
                        {
                           buildingId = String(superBuildingXML[ATTR_ID]);
                           buildingObject = new Object();
                           if(superBuildingXML.hasOwnProperty(ATTR_NAME) && superBuildingXML.hasOwnProperty(ATTR_MAX))
                           {
                              buildingObject[KEY_NAME] = String(superBuildingXML[ATTR_NAME]);
                              buildingObject[KEY_MAX] = String(superBuildingXML[ATTR_MAX]);
                              this.m_superBuildings[buildingId] = buildingObject;
                           }
                        }
                     }
                     break;
                  case NODE_SEASONS:
                     this.m_seasons = new Object();
                     for each(seasonXML in childXML.children())
                     {
                        if(seasonXML.hasOwnProperty(ATTR_ID))
                        {
                           seasonObject = new Object();
                           dialogObject = new Object();
                           if(seasonXML.hasOwnProperty(ATTR_NAME))
                           {
                              seasonObject[KEY_SEASON_NAME] = String(seasonXML[ATTR_NAME]);
                           }
                           if(seasonXML.hasOwnProperty(ATTR_EA))
                           {
                              seasonObject[KEY_SEASON_EA] = String(seasonXML[ATTR_EA]);
                           }
                           if(seasonXML.hasOwnProperty(ATTR_GA))
                           {
                              seasonObject[KEY_SEASON_GA] = String(seasonXML[ATTR_GA]);
                           }
                           if(seasonXML.hasOwnProperty(ATTR_ID))
                           {
                              seasonObject[KEY_SEASON_ID] = String(seasonXML[ATTR_ID]);
                           }
                           for each(dialogXML in seasonXML.children())
                           {
                              if(dialogXML.hasOwnProperty(ATTR_EA))
                              {
                                 dialogObject[KEY_SEASON_EA] = String(dialogXML[ATTR_EA]);
                              }
                              if(dialogXML.hasOwnProperty(ATTR_GA))
                              {
                                 dialogObject[KEY_SEASON_GA] = String(dialogXML[ATTR_GA]);
                              }
                              if(dialogXML.hasOwnProperty(ATTR_UNLOCK))
                              {
                                 dialogObject[KEY_SEASON_UNLOCK] = String(dialogXML[ATTR_UNLOCK]);
                              }
                              seasonObject[KEY_SEASON_DIALOG] = dialogObject;
                           }
                           this.m_seasons[String(seasonXML[ATTR_ID])] = seasonObject;
                        }
                     }
                     break;
                  case NODE_SHIPPING_LICENSE_ITEM_NAME:
                     this.m_shippingLicenseItemName = childXML.toString();
                     break;
                  case NODE_BUSHEL_CHANCE_SCALE:
                     this.m_bushelChanceScale = parseFloat(childXML.toString());
                     break;
                  case NODE_WORLD_REQUIREMENT_OVERRIDE:
                     this.m_worldRequirementOverride = childXML.toString();
                     break;
                  case NODE_SHOW_IN_TRAVEL_DIALOG:
                     this.m_showInTravelDialog = childXML.toString() as Boolean;
                     break;
                  case NODE_STATIC_WORLD:
                     this.m_staticWorld = childXML.toString() == "true" ? true : false;
                     break;
                  case NODE_EARLY_ACCESS_GIFTING:
                     this.m_earlyAccessGifting = new ExpansionEarlyAccessGiftingData(this.m_name,childXML);
                     break;
                  case NODE_PREREQS:
                     this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.children());
               }
            }
            return;
         }
         throw new Error("Cannot construct an expansion object from null XML");
      }
      
      public function get worldId() : String
      {
         return this.m_name;
      }
      
      public function get seasonNumber() : int
      {
         return this.m_season;
      }
      
      public function get bushelChanceScale() : Number
      {
         return this.m_bushelChanceScale;
      }
      
      public function get showInTravelDialog() : Boolean
      {
         return this.m_showInTravelDialog;
      }
      
      public function get staticWorld() : Boolean
      {
         return this.m_staticWorld;
      }
      
      public function passesPrereqs() : Boolean
      {
         return PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs);
      }
      
      public function get worldRequirementType() : String
      {
         return this.m_worldRequirementOverride;
      }
      
      public function get currency() : String
      {
         return this.m_currency;
      }
      
      public function get scoreId() : String
      {
         return this.m_scoreId;
      }
      
      public function get score2Id() : String
      {
         return this.m_score2Id;
      }
      
      public function get scoreFile() : String
      {
         return this.m_scoreFile;
      }
      
      public function get friendlyName() : String
      {
         return ZLocUtils.t_pk(this.m_friendlyNameKey);
      }
      
      public function get hudIcon() : String
      {
         return this.m_hudIcon;
      }
      
      public function get moreInfoDialog() : String
      {
         return this.m_moreInfoDialog;
      }
      
      public function get shippingLicenseItemName() : String
      {
         return this.m_shippingLicenseItemName;
      }
      
      public function getAccessOfType(type:String) : ExpansionAccess
      {
         var accessInfo:ExpansionAccess = null;
         if(this.m_accessTypes.hasOwnProperty(type))
         {
            accessInfo = this.m_accessTypes[type] as ExpansionAccess;
         }
         return accessInfo;
      }
      
      public function get plotLimits() : ExpansionPlotLimits
      {
         return this.m_plotLimits;
      }
      
      public function get farmingAttributes() : FarmingAttributes
      {
         return this.m_farmingAttributes;
      }
      
      public function get motdAssets() : Object
      {
         return this.m_motds;
      }
      
      public function get earlyAccessGifting() : ExpansionEarlyAccessGiftingData
      {
         return this.m_earlyAccessGifting;
      }
      
      public function get seasons() : Object
      {
         return this.m_seasons;
      }
      
      public function get superBuildings() : Object
      {
         return this.m_superBuildings;
      }
   }
}

