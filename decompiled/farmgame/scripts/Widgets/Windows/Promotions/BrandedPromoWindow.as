package Widgets.Windows.Promotions
{
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class BrandedPromoWindow extends FarmWindow
   {
      
      protected const ASSET_URL:String = "";
      
      protected const TITLE_ICON_SIZE:int = 65;
      
      protected const REWARD_ICON_SIZE:int = 100;
      
      protected var m_localizeTextPrefix:String = "";
      
      protected var m_promoName:String;
      
      protected var m_closeCallback:Function;
      
      public function BrandedPromoWindow(promoName:String, closeCallback:Function, assetPath:String = "")
      {
         super(assetPath);
         this.m_promoName = promoName;
         this.m_closeCallback = closeCallback;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var rewardIcon0:FarmIcon = null;
         var rewardIcon1:FarmIcon = null;
         super.onLoadComplete(event);
         var textPrefix:String = this.getLocalizeTextPrefix() + "_" + this.m_promoName + "_";
         if(Global.farmGameSettingsManager.getString("promoFarmItemIcon0_" + this.m_promoName) != "")
         {
            rewardIcon0 = new FarmIcon(m_window.iconSlot0_mc,Global.farmGameSettingsManager.getString("promoFarmItemIcon0_" + this.m_promoName));
            rewardIcon0.setIconSize(this.REWARD_ICON_SIZE,this.REWARD_ICON_SIZE);
            addWidget(rewardIcon0);
         }
         if(Global.farmGameSettingsManager.getString("promoFarmItemIcon1_" + this.m_promoName) != "")
         {
            rewardIcon1 = new FarmIcon(m_window.iconSlot1_mc,Global.farmGameSettingsManager.getString("promoFarmItemIcon1_" + this.m_promoName));
            rewardIcon1.setIconSize(this.REWARD_ICON_SIZE,this.REWARD_ICON_SIZE);
            addWidget(rewardIcon1);
         }
         this.setupButtons();
      }
      
      protected function setupButtons() : void
      {
      }
      
      protected function getLocalizeTextPrefix() : String
      {
         return this.m_localizeTextPrefix;
      }
      
      protected function onAccept(event:Event) : void
      {
         close();
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(true);
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         close();
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(false);
         }
      }
   }
}

