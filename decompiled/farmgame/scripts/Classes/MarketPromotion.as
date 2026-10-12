package Classes
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   
   public class MarketPromotion
   {
      
      public static const DEFAULT_TITLE_FONT:String = "Merkin2";
      
      public static const DEFAULT_SUB_FONT:String = "Merkin2";
      
      public static const DEFAULT_TITLE_COLOR:Number = 0;
      
      public static const DEFAULT_SUB_COLOR:Number = 656649;
      
      public static const PROMO_SIZE_SMALL:String = "small";
      
      public static const PROMO_SIZE_MEDIUM:String = "medium";
      
      public static const PROMO_SIZE_LARGE:String = "large";
      
      private var m_name:String;
      
      private var m_titleFont:String;
      
      private var m_titleColor:Number;
      
      private var m_subFont:String;
      
      private var m_subColor:Number;
      
      private var m_assetUrl:String;
      
      private var m_assetName:String;
      
      private var m_backgroundUrl:String;
      
      private var m_backgroundName:String;
      
      private var m_action:String;
      
      private var m_params:Array;
      
      private var m_titleText:String = null;
      
      private var m_subText:String = null;
      
      private var m_btnText:String = null;
      
      private var m_timedSlot:String = "";
      
      private var m_timedLimitedStart:String = "";
      
      private var m_timedLimitedEnd:String = "";
      
      private var m_size:String = "medium";
      
      private var m_minRequiredLevel:int = 0;
      
      private var m_experiment:String;
      
      private var m_variants:Array;
      
      private var m_geoip:XMLList = null;
      
      private var m_requirements:Array = null;
      
      public function MarketPromotion(name:String, asset:String, size:String, background:String, titleFont:String, titleColor:Number, subFont:String, subColor:Number, action:String, params:Array, timerObj:Object, minLevel:int, experiment:String, variants:Array, geoip:XMLList, requirements:Array = null)
      {
         super();
         this.m_name = name;
         if(FarmGameSettingsManager.isInMarketDataAssetCallExperiment())
         {
            this.m_assetName = asset;
            this.m_backgroundName = background;
         }
         else
         {
            this.m_assetUrl = MarketConfigSettings.getMarketDialogAssetFullPath(asset,false);
            this.m_backgroundUrl = MarketConfigSettings.getMarketDialogSupportFullPath(background,false);
         }
         this.m_size = size;
         this.m_titleFont = titleFont;
         this.m_titleColor = titleColor;
         this.m_subFont = subFont;
         this.m_subColor = subColor;
         this.m_action = action;
         this.m_params = params;
         this.m_timedSlot = timerObj.slot;
         this.m_timedLimitedStart = timerObj.limitedStart;
         this.m_timedLimitedEnd = timerObj.limitedEnd;
         this.m_minRequiredLevel = minLevel;
         this.m_experiment = experiment;
         this.m_variants = variants;
         this.m_geoip = geoip;
         this.m_requirements = requirements;
      }
      
      public static function fromXML(xml:XML) : MarketPromotion
      {
         var variantList:XMLList = null;
         var variantItem:XML = null;
         var name:String = xml.@name;
         var timerData:XML = xml.timer[0];
         var appearance:XML = xml.appearance[0];
         var asset:String = appearance.@asset;
         var background:String = appearance.@background;
         var titleFont:String = DEFAULT_TITLE_FONT;
         var titleColor:Number = DEFAULT_TITLE_COLOR;
         var subFont:String = DEFAULT_SUB_FONT;
         var subColor:Number = DEFAULT_SUB_COLOR;
         var size:String = appearance.@size;
         var minLevel:int = int(xml.@level);
         if(!size)
         {
            size = PROMO_SIZE_MEDIUM;
         }
         if(appearance.attribute("title_font").toString())
         {
            titleFont = appearance.attribute("title_font").toString();
         }
         if(appearance.attribute("title_color").toString())
         {
            titleColor = Number(appearance.@title_color);
         }
         if(appearance.attribute("sub_font").toString())
         {
            subFont = appearance.attribute("sub_font").toString();
         }
         if(appearance.attribute("sub_color").toString())
         {
            subColor = Number(appearance.@sub_color);
         }
         var click:XML = xml.click[0];
         var action:String = click.@action;
         var params:Array = [];
         if(click.attribute("params").toString())
         {
            params = click.attribute("params").toString().split(",");
         }
         var timerObj:Object = {};
         if(timerData != null)
         {
            timerObj.slot = String(timerData.@slot);
            timerObj.limitedStart = String(timerData.@limitedStart);
            timerObj.limitedEnd = String(timerData.@limitedEnd);
         }
         var experiment:String = xml.experiment.@name;
         var variants:Array = null;
         if(experiment)
         {
            variants = new Array();
            variantList = xml.experiment.variant;
            for each(variantItem in variantList.children())
            {
               variants.push(int(variantItem));
            }
         }
         var geoip:XMLList = null;
         if(xml.hasOwnProperty("geoip"))
         {
            geoip = xml.geoip;
         }
         var requirements:Array = null;
         if(xml.hasOwnProperty("prereqs"))
         {
            requirements = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.prereq);
         }
         return new MarketPromotion(name,asset,size,background,titleFont,titleColor,subFont,subColor,action,params,timerObj,minLevel,experiment,variants,geoip,requirements);
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get asset() : String
      {
         if(FarmGameSettingsManager.isInMarketDataAssetCallExperiment())
         {
            return MarketConfigSettings.getMarketDialogAssetFullPath(this.m_assetName,false);
         }
         return this.m_assetUrl;
      }
      
      public function get background() : String
      {
         if(FarmGameSettingsManager.isInMarketDataAssetCallExperiment())
         {
            return MarketConfigSettings.getMarketDialogSupportFullPath(this.m_backgroundName,false);
         }
         return this.m_backgroundUrl;
      }
      
      public function get titleColor() : Number
      {
         return this.m_titleColor;
      }
      
      public function get titleFont() : String
      {
         return this.m_titleFont;
      }
      
      public function get subColor() : Number
      {
         return this.m_subColor;
      }
      
      public function get subFont() : String
      {
         return this.m_subFont;
      }
      
      public function get action() : String
      {
         return this.m_action;
      }
      
      public function get timedSlot() : String
      {
         return this.m_timedSlot;
      }
      
      public function get timedLimitedStart() : String
      {
         return this.m_timedLimitedStart;
      }
      
      public function get timedLimitedEnd() : String
      {
         return this.m_timedLimitedEnd;
      }
      
      public function get actionParams() : Array
      {
         return this.m_params;
      }
      
      public function get localizedTitle() : String
      {
         if(this.m_titleText == null)
         {
            if(ZLocUtils.hasString("Dialogs","MarketPromo_Title_" + this.name))
            {
               this.m_titleText = ZLocUtils.t("Dialogs","MarketPromo_Title_" + this.name);
            }
            else
            {
               this.m_titleText = "";
            }
         }
         return this.m_titleText;
      }
      
      public function get localizedSubTitle() : String
      {
         if(this.m_subText == null)
         {
            if(ZLocUtils.hasString("Dialogs","MarketPromo_SubTitle_" + this.name))
            {
               this.m_subText = ZLocUtils.t("Dialogs","MarketPromo_SubTitle_" + this.name);
            }
            else
            {
               this.m_subText = "";
            }
         }
         return this.m_subText;
      }
      
      public function get localizedBtnText() : String
      {
         if(this.m_btnText == null)
         {
            if(Global.marketConfigSettings.isLERevampActive())
            {
               this.m_btnText = ZLocUtils.t("Dialogs","MarketPromo_ActionButton_LeRevamp");
            }
            else
            {
               this.m_btnText = ZLocUtils.t("Dialogs","MarketPromo_ActionButton_" + this.name);
            }
         }
         return this.m_btnText;
      }
      
      public function get size() : String
      {
         return this.m_size;
      }
      
      public function get minRequiredLevel() : int
      {
         return this.m_minRequiredLevel;
      }
      
      public function get experiment() : String
      {
         return this.m_experiment;
      }
      
      public function hasExperiment() : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.m_experiment) && Boolean(this.m_variants) && this.m_variants.length > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function isInExperiment() : Boolean
      {
         var result:Boolean = true;
         if(this.hasExperiment())
         {
            result = this.m_variants.indexOf(Global.experimentManager.getExperimentVariant(this.m_experiment)) >= 0 ? true : false;
         }
         return result;
      }
      
      public function isValidInUserArea() : Boolean
      {
         var result:Boolean = true;
         if(this.m_geoip)
         {
            result = Global.geoIpManager.checkGeoGate(this.m_geoip);
         }
         return result;
      }
      
      public function checkPrerequisites(ignoreDate:Boolean = false) : Boolean
      {
         var i:int = 0;
         var prereqParams:Object = null;
         var result:Boolean = true;
         if(!FarmGameUtil.checkDateGate(this.timedLimitedStart,this.timedLimitedEnd) && !ignoreDate || !this.isInExperiment() || !this.isValidInUserArea())
         {
            result = false;
         }
         if(Boolean(result) && Boolean(this.m_requirements) && this.m_requirements.length > 0)
         {
            for(i = 0; i < this.m_requirements.length; i++)
            {
               prereqParams = this.m_requirements[i];
               if(ignoreDate)
               {
                  prereqParams[PrerequisiteConstants.META_IGNORE_DATE] = 1;
               }
               if(!PrerequisiteUtility.isPrerequisiteMet(prereqParams))
               {
                  result = false;
                  break;
               }
            }
         }
         return result;
      }
   }
}

