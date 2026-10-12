package Classes.MOTD
{
   import Cache.Classes.ZCacheCapabilities;
   import Cache.Interfaces.IZCache;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.ToasterManager;
   import Transactions.TGrantZCacheGift;
   import Widgets.Windows.ZCacheToasterWindow;
   
   public class ZCacheMOTDHandler extends MOTDHandler
   {
      
      public static const ZCACHE_GIFT_GIVEN:String = "zcache_gift_given";
      
      public static const ZCACHE_GIFT_GIVEN_TOASTER:int = 2;
      
      public static const ZCACHE_GIFT_GIVEN_ON_MOTD:int = 1;
      
      public static const ZCACHE_GIFT_GIVEN_RETROACTIVELY:int = 0;
      
      private static const MOTD_DIALOG_NAME:String = "MotdZCache";
      
      private static const MOTD_REPROMPT_DIALOG_NAME:String = "motd_BaseDialog";
      
      private var m_isZCacheEnableOptionAvailable:Boolean = false;
      
      private var m_dialogPopup:DataDrivenOkayPopup;
      
      public function ZCacheMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var farmItem:FarmItem = null;
         var farmItemName:String = null;
         var params:Array = null;
         var zCache:IZCache = GlobalZCache.instance;
         if(zCache)
         {
            if(zCache.allowed)
            {
               StatsManager.count("zcache","motd","suppressed","enabled");
            }
            else if(!ZCacheCapabilities.isZCacheCompatible())
            {
               StatsManager.count("zcache","motd","suppressed","incompatible");
            }
            else
            {
               this.m_isZCacheEnableOptionAvailable = true;
               farmItem = Global.farmGameSettingsManager.getFarmItemByName(Global.farmGameSettingsManager.getString("enabledZCacheGiftName"));
               farmItemName = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
               params = new Array();
               params.push(m_currentMOTD["icon"].toString());
               params.push(ZLocUtils.t_pk(m_currentMOTD["text"],null,{"itemName":farmItemName}));
               params.push(ZLocUtils.t_pk(m_currentMOTD["title"]));
               params.push(ZLocUtils.t_pk(m_currentMOTD["buttonText"]));
               this.m_dialogPopup = new DataDrivenOkayPopup(MOTD_DIALOG_NAME,params,this.acceptMOTD,this.cancelMOTD);
               UI.displayPopup(this.m_dialogPopup,false);
               ztrack("view");
               Global.player.setSeenSessionFlag(MOTD.SEEN_MOTD_SESSION_FLAG);
            }
         }
         else
         {
            StatsManager.count("zcache","motd","suppressed","no zCache");
         }
         ztrack("impressions");
         m_isFinished = true;
      }
      
      private function cancelMOTD() : void
      {
         this.m_dialogPopup.close();
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(Global.farmGameSettingsManager.getString("enabledZCacheGiftName"));
         var farmItemName:String = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
         var params:Array = new Array();
         params.push(m_currentMOTD["icon"].toString());
         params.push(ZLocUtils.t_pk(m_currentMOTD["text_prompt"],null,{"itemName":farmItemName}));
         params.push(ZLocUtils.t_pk(m_currentMOTD["title_prompt"]));
         params.push(ZLocUtils.t_pk(m_currentMOTD["buttonText_prompt"]));
         params.push(ZLocUtils.t_pk(m_currentMOTD["cancelText_prompt"]));
         this.m_dialogPopup = new DataDrivenOkayPopup(MOTD_REPROMPT_DIALOG_NAME,params,this.acceptMOTD,this.showToaster);
         UI.displayPopup(this.m_dialogPopup,false);
      }
      
      private function showToaster() : void
      {
         super.closeMOTD();
         var toaster:ZCacheToasterWindow = new ZCacheToasterWindow(ZCacheToasterWindow.TYPE_REMINDER);
         ToasterManager.getInstance().add(toaster);
      }
      
      override protected function acceptMOTD() : void
      {
         if(this.m_isZCacheEnableOptionAvailable)
         {
            FarmGameUtil.showZCachePermissionsPrompt(this.onPermissionsResponse);
         }
         super.acceptMOTD();
      }
      
      override protected function closeMOTD() : void
      {
         super.closeMOTD();
      }
      
      private function onPermissionsResponse(allowed:Boolean) : void
      {
         if(allowed && !Global.player.getSeenFlag(ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN))
         {
            TransactionManager.addTransaction(new TGrantZCacheGift(ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN_ON_MOTD),true);
         }
      }
   }
}

