package Classes.MOTD
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import flash.system.Capabilities;
   
   public class FlashUpgradeMOTDHandler extends MOTDHandler
   {
      
      public static const FLASH_UPGRADE_GIFT_GIVEN:String = "flash_upgrade_gift_given";
      
      private static const MOTD_DIALOG_NAME:String = "MotdFlashUpgrade";
      
      private static const MOTD_REPROMPT_DIALOG_NAME:String = "motd_BaseDialog_with_close_btn";
      
      private static const REGEX_VERSION:RegExp = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/;
      
      private static const FLASH_UPGRADE_GIFT_DEFINITION:String = "FlashUpgradeGiftName";
      
      private static var m_flashVersion:Object = null;
      
      private var m_isFlashUpgradeEnableOptionAvailable:Boolean = false;
      
      private var m_dialogPopup:DataDrivenOkayPopup;
      
      private var m_acceptedMOTD:Boolean = false;
      
      public function FlashUpgradeMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      public static function isGiftGrantable() : Boolean
      {
         return isFlashVersionCompatible() && !Global.player.getSeenFlag(FlashUpgradeMOTDHandler.FLASH_UPGRADE_GIFT_GIVEN);
      }
      
      private static function parseFlashVersion() : void
      {
         var versionString:String = null;
         if(m_flashVersion === null)
         {
            versionString = Capabilities.version;
            m_flashVersion = REGEX_VERSION.exec(versionString);
            REGEX_VERSION.lastIndex = 0;
         }
      }
      
      private static function isFlashVersionCompatible() : Boolean
      {
         parseFlashVersion();
         var majorVersion:int = int(m_flashVersion[2]);
         var minorVersion:int = int(m_flashVersion[3]);
         var isFlashCompatible:Boolean = false;
         if(majorVersion > 12 || majorVersion >= 11 && minorVersion > 1)
         {
            isFlashCompatible = true;
         }
         return isFlashCompatible;
      }
      
      override public function execute() : void
      {
         var farmItem:FarmItem = null;
         var farmItemName:String = null;
         var params:Array = null;
         var flashVersionHigh:Boolean = isFlashVersionCompatible();
         var suppressMOTD:Boolean = false;
         if(m_currentMOTD["checkGiftSeenFlag"] !== null && m_currentMOTD["checkGiftSeenFlag"] === "true")
         {
            if(Global.player.getSeenFlag(FlashUpgradeMOTDHandler.FLASH_UPGRADE_GIFT_GIVEN))
            {
               suppressMOTD = true;
            }
         }
         if(flashVersionHigh || suppressMOTD)
         {
            StatsManager.count("flash_upgrade","motd","suppressed","enabled");
            if(m_currentMOTD["checkGiftSeenFlag"] !== null && m_currentMOTD["checkGiftSeenFlag"] === "true")
            {
               closeMOTD();
            }
         }
         else
         {
            this.m_isFlashUpgradeEnableOptionAvailable = true;
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(Global.farmGameSettingsManager.getString(FLASH_UPGRADE_GIFT_DEFINITION));
            farmItemName = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
            params = new Array();
            params.push(m_currentMOTD["icon"].toString());
            params.push(ZLocUtils.t_pk(m_currentMOTD["text"],null,{"itemName":farmItemName}));
            params.push(ZLocUtils.t_pk(m_currentMOTD["title"]));
            params.push(ZLocUtils.t_pk(m_currentMOTD["buttonText"]));
            this.m_dialogPopup = new DataDrivenOkayPopup(MOTD_DIALOG_NAME,params,this.acceptMOTD,this.cancelPrompt);
            UI.displayPopup(this.m_dialogPopup,false);
            ztrack("view");
            Global.player.setSeenSessionFlag(MOTD.SEEN_MOTD_SESSION_FLAG);
         }
         ztrack("impressions");
         m_isFinished = true;
      }
      
      public function cancelPrompt() : void
      {
         this.m_dialogPopup.close();
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(Global.farmGameSettingsManager.getString("FlashUpgradeGiftName"));
         var farmItemName:String = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
         parseFlashVersion();
         var flashVersion:String = m_flashVersion[2] + "." + m_flashVersion[3];
         var params:Array = new Array();
         params.push(m_currentMOTD["icon"].toString());
         params.push(ZLocUtils.t_pk(m_currentMOTD["text_prompt"],null,{
            "itemName":farmItemName,
            "currentVersion":flashVersion
         }));
         params.push(ZLocUtils.t_pk(m_currentMOTD["title_prompt"]));
         params.push(ZLocUtils.t_pk(m_currentMOTD["buttonText_prompt"]));
         params.push(ZLocUtils.t_pk(m_currentMOTD["cancelText_prompt"]));
         StatsManager.count("dialog","flash_upgrade_promo_areyousure","view");
         this.m_dialogPopup = new DataDrivenOkayPopup(MOTD_REPROMPT_DIALOG_NAME,params,this.acceptMOTD,this.cancelRePromptDialog);
         UI.displayPopup(this.m_dialogPopup,false);
      }
      
      override protected function acceptMOTD() : void
      {
         var callId:String = null;
         if(this.m_isFlashUpgradeEnableOptionAvailable)
         {
            callId = ExternalUtil.instance.registerCallback(this.cancelPrompt);
            ExternalUtil.instance.call("FarmNS.FlashUpgrade.showInstaller",callId,this.m_acceptedMOTD);
         }
         if(!this.m_acceptedMOTD)
         {
            super.acceptMOTD();
            this.m_acceptedMOTD = true;
         }
         else
         {
            StatsManager.count("dialog","flash_upgrade_promo_areyousure","yes");
         }
      }
      
      private function cancelRePromptDialog() : void
      {
         StatsManager.count("dialog","flash_upgrade_promo_areyousure","no");
      }
   }
}

