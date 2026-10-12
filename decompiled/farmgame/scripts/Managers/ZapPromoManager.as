package Managers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Display.ZapPromotionDialog;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetZapPlaceReward;
   import Widgets.Windows.BrandPromoWindow;
   
   public class ZapPromoManager
   {
      
      public static const ZAP_EVENTS:Object = {
         "firstUseVisit":["firstuse","visit"],
         "firstUseShare":["firstuse","share"],
         "mastery":["mastery"],
         "like":["fb","like"],
         "visit":["fb","visit"],
         "cardView":["marketcard","view"],
         "cardClick":["marketcard","click"],
         "downgradeFirstUse":["downgradeFirstUse"],
         "firstUse":["firstuse"]
      };
      
      public function ZapPromoManager()
      {
         super();
      }
      
      public static function countEvent(campaign:String, event:String, objectName:String = null) : void
      {
         var eventTemplate:Array = ZAP_EVENTS[event];
         var campaignEvent:Array = ["Zyngage",campaign];
         for(var i:uint = 0; i < eventTemplate.length; i++)
         {
            campaignEvent.push(eventTemplate[i]);
         }
         if(objectName != null)
         {
            campaignEvent.push(objectName);
         }
         FarmStatsManager.count.apply(null,campaignEvent);
      }
      
      public static function tryShowFirstPlacementDialog(item:FarmItem) : void
      {
         var firstPlacementFlag:String = null;
         var promoWindow:BrandPromoWindow = null;
         var firstPlacementDialog:ZapPromotionDialog = null;
         var title:String = null;
         var topMessage:String = null;
         var bottomMessage:String = null;
         if(item.isBrandedItem)
         {
            firstPlacementFlag = item.name + "_firstPlacementFlag";
            if(!Global.player.getSeenFlag(firstPlacementFlag))
            {
               countEvent(item.brandPromoData.brandPromoName,"firstUse",item.name);
               if(item.brandPromoData.swf)
               {
                  promoWindow = new BrandPromoWindow(item);
                  UI.displayPopup(promoWindow);
               }
               else
               {
                  firstPlacementDialog = FarmDynamicDialog.createDialog("ZapFBlikeButtonDialog",ZapPromotionDialog) as ZapPromotionDialog;
                  title = ZLocUtils.t("Dialogs",item.name + "_FirstPlacementTitle");
                  topMessage = ZLocUtils.t("Dialogs",item.name + "_FirstPlacementTopMsg");
                  bottomMessage = ZLocUtils.t("Dialogs",item.name + "_FirstPlacementBottomMsg");
                  firstPlacementDialog.setDialogconfig(item,item.brandPromoData.brandUrl,title,topMessage,bottomMessage);
                  firstPlacementDialog.setup();
                  firstPlacementDialog.show(true);
               }
               Global.player.setSeenFlag(firstPlacementFlag);
            }
         }
      }
      
      public static function shareFirstPlacement(item:FarmItem) : void
      {
         TransactionManager.addTransaction(new TGetZapPlaceReward(item));
      }
      
      public static function shareFirstPlacementPublish(item:FarmItem, rewardLink:String) : void
      {
         var bundleData:Object = {
            "reward_link":rewardLink,
            "item":item.friendlyName,
            "images":[{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":item.newsfeed
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory("ZapFirstTimePlace_" + item.name,bundleData,[],false);
      }
   }
}

