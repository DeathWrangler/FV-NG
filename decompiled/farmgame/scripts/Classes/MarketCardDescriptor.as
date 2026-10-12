package Classes
{
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   
   public class MarketCardDescriptor
   {
      
      public static const DEFAULT_NAME:String = "default";
      
      private var m_name:String = "";
      
      private var m_friendlyName:String = "";
      
      private var m_backgroundAssetURL:String = null;
      
      private var m_backgroundAssetName:String = null;
      
      private var m_themeColor:uint = 0;
      
      private var m_bgGradients:Array = null;
      
      private var m_slotHeight:int = 1;
      
      public function MarketCardDescriptor(name:String, asset:String, themeColor:uint = 0, bgGradients:Array = null, slotHeight:int = 1)
      {
         super();
         this.m_name = name;
         if(FarmGameSettingsManager.isInMarketDataAssetCallExperiment())
         {
            this.m_backgroundAssetName = asset ? asset : null;
         }
         else
         {
            this.m_backgroundAssetURL = asset ? MarketConfigSettings.getMarketDialogSupportFullPath(asset) : null;
         }
         this.m_themeColor = themeColor;
         this.m_bgGradients = Boolean(bgGradients) && bgGradients.length > 0 ? bgGradients : [];
         this.m_slotHeight = slotHeight;
      }
      
      public static function fromXML(xml:XML) : MarketCardDescriptor
      {
         var gradient:XML = null;
         var card:MarketCardDescriptor = null;
         var gradientColor:uint = 0;
         var name:String = xml.@name;
         var appearance:XML = xml.appearance[0];
         var asset:String = appearance.@asset;
         var themeColor:uint = uint(appearance.@theme_color);
         var bgGradients:Array = [];
         var slotHeight:int = int(xml.@slotHeight);
         slotHeight = slotHeight > 0 ? slotHeight : 1;
         for each(gradient in appearance.descendants("gradient"))
         {
            gradientColor = uint(gradient.@color);
            bgGradients.push(gradientColor);
         }
         return new MarketCardDescriptor(name,asset,themeColor,bgGradients,slotHeight);
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get friendlyName() : String
      {
         if(this.m_friendlyName == "")
         {
            this.m_friendlyName = ZLocUtils.t("Dialogs","theme_" + this.name);
         }
         return this.m_friendlyName;
      }
      
      public function get assetUrl() : String
      {
         if(FarmGameSettingsManager.isInMarketDataAssetCallExperiment())
         {
            return MarketConfigSettings.getMarketDialogSupportFullPath(this.m_backgroundAssetName);
         }
         return this.m_backgroundAssetURL;
      }
      
      public function get fontColor() : uint
      {
         return 5325357;
      }
      
      public function get themeColor() : uint
      {
         return this.m_themeColor;
      }
      
      public function hasBackgroundGradient() : Boolean
      {
         return this.m_bgGradients.length > 0;
      }
      
      public function get gradientColors() : Array
      {
         return this.m_bgGradients;
      }
      
      public function get slotHeight() : int
      {
         return this.m_slotHeight;
      }
   }
}

