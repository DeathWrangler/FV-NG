package Widgets.Windows
{
   import Classes.Animal;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Plot;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class MarketplaceGiftingSuccess extends FarmWindow
   {
      
      protected static var m_DialogResource:String = "assets/dialogs/FV_MarketplaceGifting_Congrats.swf";
      
      private var m_giftItem:FarmItem;
      
      private var m_okayButton:ZwButton = null;
      
      private var m_congratsBanner:ZwTextField = null;
      
      private var m_giftObject:ObjectPreviewFrame = null;
      
      private var m_congratsText:ZwTextField = null;
      
      private var m_friendSelectorCloser:Function = null;
      
      private var m_titleText:ZwTextField = null;
      
      private var m_numFriendsSent:int = 0;
      
      private var m_giftingStatsCounter:String = StatsTrackingConstants.MARKETPLACE_GIFTING;
      
      public function MarketplaceGiftingSuccess(numFriends:int, giftItem:FarmItem, closerCallback:Function = null, giftingStatsCounter:String = null)
      {
         this.m_giftItem = giftItem;
         this.m_numFriendsSent = numFriends;
         this.m_friendSelectorCloser = closerCallback;
         if(giftingStatsCounter != null)
         {
            this.m_giftingStatsCounter = giftingStatsCounter;
         }
         super(m_DialogResource,true,false);
      }
      
      override protected function postLoadComplete() : void
      {
         var terrainOverlayName:String = null;
         super.postLoadComplete();
         if(m_window.mc_background)
         {
            addWidget(new ZwWidget(m_window.mc_background));
         }
         if(m_window.mc_header)
         {
            addWidget(new ZwWidget(m_window.mc_header));
         }
         m_closeButton = addWidget(new FarmButton(m_window.delay_close_bt,this.onClose)) as FarmButton;
         m_closeButton.visible = true;
         this.m_okayButton = addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","Okay1"),this.onClose)) as ZwButton;
         this.m_okayButton.visible = true;
         this.m_congratsBanner = addWidget(new FarmTextField(m_window.congrats_tf,ZLocUtils.t("Dialogs","MarketplaceGifting_Congrats"))) as ZwTextField;
         this.m_congratsBanner.visible = true;
         this.m_congratsText = addWidget(new FarmTextField(m_window.description_tf,ZLocUtils.t("Dialogs","MarketplaceGifting_Pat",{"friends":this.m_numFriendsSent}))) as ZwTextField;
         this.m_congratsText.visible = true;
         this.m_titleText = addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t("Dialogs","MarketplaceGifting_SentTitle"))) as ZwTextField;
         this.m_titleText.visible = true;
         var terrain:String = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(this.m_giftItem.getTerrainCodes());
         if(terrain != FarmGameSettingsManager.TERRAIN_DEFAULT)
         {
            terrainOverlayName = terrain + "_mc";
            if(m_window.hasOwnProperty(terrainOverlayName))
            {
               addWidget(new ZwWidget(m_window[terrainOverlayName]),true);
            }
         }
         var itemState:String = "";
         var scale:Number = 2.4;
         switch(this.m_giftItem.type)
         {
            case "seed":
            case "plot":
               itemState = Plot.STATE_GROWN;
               break;
            case "tree":
               itemState = SimpleHarvestableResource.STATE_RIPE;
               scale = 2;
               break;
            case "animal":
            case "gopher":
               itemState = Animal.STATE_FRONT_IDLE;
               scale = this.m_giftItem.sizeX == 1 ? 3.5 : 3.25;
         }
         this.showObjectPreview(scale,itemState);
         FarmStatsManager.count(this.m_giftingStatsCounter,"action_summary","impressions");
      }
      
      protected function showObjectPreview(scale:Number, itemState:String) : void
      {
         this.m_giftObject = new ObjectPreviewFrame(m_window.item_mc,this.m_giftItem,null,[scale],null,itemState);
         addWidget(this.m_giftObject,true);
         this.m_giftObject.visible = true;
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(this.m_giftingStatsCounter,"action_summary","close_click");
         if(this.m_friendSelectorCloser != null)
         {
            this.m_friendSelectorCloser();
         }
         super.onClose(event);
      }
   }
}

