package Transactions
{
   import Classes.MOTD.ZCacheMOTDHandler;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.geom.Point;
   
   public class TGrantZCacheGift extends TFarmTransaction
   {
      
      private var m_motdSeenType:int;
      
      public function TGrantZCacheGift(motdSeenType:int)
      {
         this.m_motdSeenType = motdSeenType;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ZCacheGiftService.grantZCacheEnabledGift");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var giftItem:FarmItem = null;
         var assetPath:String = null;
         var textTitle:String = null;
         var textSubtitle:String = null;
         if(Boolean(result != null && result.receivedZCacheGift) && Boolean(result.receivedZCacheGift == "true") && Boolean(result.giftName))
         {
            Global.player.addGift(result.giftName);
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(result.giftName);
            assetPath = giftItem.icon;
            textTitle = ZLocUtils.t("Dialogs","ZCacheToasterReward_Title");
            textSubtitle = ZLocUtils.t("Dialogs","ZCacheToasterReward_Subtitle",{"item":ZLocUtils.tk_pk_asTitle(giftItem.friendlyName)});
            ToasterManager.getInstance().togglePause(false);
            ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(textTitle,textSubtitle,assetPath,"","assets/dialogs/FV_BannerAd_Rewards_generic.swf",1,1,new Point(-33,-25)));
            if(this.m_motdSeenType == ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN_RETROACTIVELY)
            {
               FarmStatsManager.count("zcache_enabled","incentive_item_granted_retroactively");
            }
            else if(this.m_motdSeenType == ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN_ON_MOTD)
            {
               FarmStatsManager.count("zcache_enabled","incentive_item_granted_new","motd");
            }
            else if(this.m_motdSeenType == ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN_TOASTER)
            {
               FarmStatsManager.count("zcache_enabled","incentive_item_granted_new","toaster");
            }
         }
      }
   }
}

