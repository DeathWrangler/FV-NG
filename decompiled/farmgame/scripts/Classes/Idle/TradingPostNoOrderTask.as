package Classes.Idle
{
   import Classes.ImageLoader;
   import Classes.Trading.TradingPostConstants;
   import Classes.TradingPostBuilding;
   import Classes.UGC.UGCTradingPostFeedImage;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.UserContentManager;
   import flash.display.DisplayObject;
   
   public class TradingPostNoOrderTask extends BaseIdleTask
   {
      
      private var m_fired:Boolean = false;
      
      private var m_farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("tradingpost");
      
      private var m_itemCode:String = null;
      
      private var m_imageLoader:ImageLoader = null;
      
      protected var m_cropImage:DisplayObject = null;
      
      protected var m_feedImage:String = "";
      
      public function TradingPostNoOrderTask(itemCode:String)
      {
         this.m_itemCode = itemCode;
         var harvestedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         this.m_imageLoader = ImageLoader.getInstance(harvestedItem.icon);
         this.m_imageLoader.getContent(this.onCropImageLoad);
         m_displaysPopup = true;
         super();
      }
      
      protected function onCropImageLoad(content:DisplayObject, info:Object = null) : void
      {
         if(content != null)
         {
            this.m_cropImage = content;
         }
      }
      
      override public function get canFire() : Boolean
      {
         return true;
      }
      
      override public function fire() : void
      {
         var tradingPostBuildings:Array = null;
         var tradingPost:TradingPostBuilding = null;
         var ugcImage:UGCTradingPostFeedImage = null;
         if(!this.m_fired)
         {
            this.m_fired = true;
            tradingPostBuildings = Global.world.getObjectsByClass(TradingPostBuilding);
            if(tradingPostBuildings.length > 0)
            {
               tradingPost = tradingPostBuildings[0];
               tradingPost.removeArrowIndicator();
               ugcImage = new UGCTradingPostFeedImage(tradingPost,UserContentManager.FEATURE_TRADING_POST,this.m_cropImage);
               UserContentManager.getInstance().createFeedImage(ugcImage,this.onFeedImageGenerated);
            }
         }
      }
      
      private function onFeedImageGenerated(result:Object) : void
      {
         this.m_feedImage = result.imagePath;
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","tradingpost_UI_no_orders"),GenericPopup.TYPE_SHARECHECKBOX,this.onShare,this.m_feedImage,false,false,"",false,GenericIconPopup.GENERIC_CALLOUT_ASSET_CHECKBOX,null,false,false,ZLocUtils.t("Dialogs","tradingpost_UI_no_orders_checkbox")));
         }
         else
         {
            UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","tradingpost_UI_no_orders"),GenericPopup.TYPE_SHARECANCEL,this.onShare,this.m_feedImage));
         }
         Global.player.setSeenSessionFlag(TradingPostConstants.SEEN_TRADING_NO_ORDER_PROMPT);
      }
      
      private function onShare(event:GenericPopupEvent) : void
      {
         var harvestedItem:FarmItem = null;
         var placeOrderUrl:String = null;
         var bundleData:Object = null;
         var messageType:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            harvestedItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
            placeOrderUrl = "trading_post_order_place.php?frHost=" + Global.player.uid + "&orderType=crop_order&orderItem=" + this.m_itemCode;
            bundleData = {
               "images":[{
                  "href":"{SN_APP_URL}" + placeOrderUrl,
                  "src":this.m_feedImage
               }],
               "user":Global.player.firstName,
               "cropName":harvestedItem.friendlyTitle,
               "place_order_url":placeOrderUrl
            };
            messageType = this.m_farmItem.name + "_NoOrder";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
      }
   }
}

