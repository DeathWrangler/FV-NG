package Classes
{
   import Classes.Constants.Experiments;
   import Classes.MOTD.CustomActionMOTDHandler;
   import Classes.util.ExternalUtil;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Managers.ToasterManager;
   import Transactions.TCIPGdp;
   import Transactions.TCIPTos;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.geom.Point;
   
   public class CIPStartNow
   {
      
      private static var IS_CIP:Boolean;
      
      private static var m_isCIPInitialised:Boolean = false;
      
      public static const GDP_SEEN_FLAG:String = "cip_gdp_seen";
      
      private static const STARTER_DIALOG:String = "CIPStarterPack";
      
      private static const DIALOG_ICON_1:String = "assets/dialogs/4d_elements/MOTD/StartNow_MOTD_1.png";
      
      private static const DIALOG_ICON_2:String = "assets/dialogs/4d_elements/MOTD/StartNow_MOTD_2.png";
      
      private static const DIALOG_ICON_3:String = "assets/dialogs/4d_elements/MOTD/StartNow_MOTD_3.png";
      
      private static const CIP_TEXT_1:String = "CIP_TEXT_1";
      
      private static const CIP_TEXT_2:String = "CIP_TEXT_2";
      
      private static const CIP_TEXT_3:String = "CIP_TEXT_3";
      
      public function CIPStartNow()
      {
         super();
      }
      
      public static function isCIP() : Boolean
      {
         if(!m_isCIPInitialised)
         {
            if(GlobalEngine.getFlashVar("isCIP") === "true")
            {
               IS_CIP = true;
            }
            else
            {
               IS_CIP = false;
            }
            m_isCIPInitialised = true;
         }
         return IS_CIP;
      }
      
      public static function canShowGDP() : Boolean
      {
         return isCIP() && !Global.player.getSeenFlag(GDP_SEEN_FLAG);
      }
      
      public static function showStarterPack() : void
      {
         var icon:String = null;
         var text:String = null;
         var variant:int = 0;
         var params:Array = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_INCENTIVISED_GDP) > 1)
         {
            icon = DIALOG_ICON_1;
            text = CIP_TEXT_1;
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_INCENTIVISED_GDP_REWARDS);
            StatsManager.count("dialog","view","startnow_pregdp");
            if(variant == 2)
            {
               icon = DIALOG_ICON_2;
               text = CIP_TEXT_2;
            }
            else if(variant == 3)
            {
               icon = DIALOG_ICON_3;
               text = CIP_TEXT_3;
            }
            params = new Array();
            params.push(icon);
            params.push(ZLocUtils.t_pk("Dialogs",text));
            params.push(ZLocUtils.t("Dialogs","CIP_Title"));
            params.push("Lets do it");
            UI.displayPopup(new DataDrivenOkayPopup(STARTER_DIALOG,params,acceptStarterPack,closeStarterPack));
         }
         else
         {
            acceptStarterPack();
         }
      }
      
      private static function closeStarterPack() : void
      {
         StatsManager.count("dialog","dismiss","startnow_pregdp");
         popupTOS();
      }
      
      private static function acceptStarterPack() : void
      {
         var callback:Function = function(response:Object, permGranted:Boolean):void
         {
            var permissionGranted:Boolean = false;
            if(permGranted)
            {
               permissionGranted = true;
            }
            if(permissionGranted)
            {
               StatsManager.count("startnow","accept_gdp");
               TransactionManager.addTransaction(new TCIPGdp());
            }
            else
            {
               StatsManager.count("startnow","reject_gdp");
               popupTOS();
            }
            Global.player.setSeenFlag(GDP_SEEN_FLAG);
         };
         var callId:String = ExternalUtil.instance.registerCallback(callback);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_INCENTIVISED_GDP) > 1)
         {
            StatsManager.count("dialog","click","startnow_pregdp");
         }
         StatsManager.count("startnow","view_gdp");
         ExternalUtil.instance.call(ExtendedPermissionState.API_ASK_PERMS,callId,ExtendedPermissionState.EXTENDED_PERMS_LIST_CIP,true);
      }
      
      private static function popupTOS() : void
      {
         var tosCallBack:Function;
         StatsManager.count("dialog","view","startnow_tos");
         tosCallBack = function():void
         {
            TransactionManager.addTransaction(new TCIPTos());
         };
         CustomActionMOTDHandler.showTOS(tosCallBack);
      }
      
      public static function shouldAutoNeighbor() : Boolean
      {
         return CIPStartNow.isCIP() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_AUTO_NEIGHBOR) > 1;
      }
      
      public static function addStarterPack() : void
      {
         var genericItemToaster:TwoIconTitleToasterWindow = null;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_INCENTIVISED_GDP_REWARDS);
         var message:String = "";
         var messageHeader:String = ZLocUtils.t("Dialogs","CIP_ToasterRewardTitle");
         var iconUrl:String = "";
         if(variant < 2)
         {
            Global.player.addGift("cow");
            Global.player.addGift("cherry");
            Global.player.addGift("pkg_unwither_1");
            iconUrl = Global.farmGameSettingsManager.getFarmItemByName("cherry").iconUrl;
            message = ZLocUtils.t("Dialogs","CIP_ToasterRewardText_1");
         }
         else
         {
            switch(variant)
            {
               case 2:
                  Global.player.addGift("cow");
                  iconUrl = Global.farmGameSettingsManager.getFarmItemByName("cow").iconUrl;
                  message = ZLocUtils.t("Dialogs","CIP_ToasterRewardText_2");
                  break;
               case 3:
                  Global.player.updateWorldCurrency(Currency.COINS,10000);
                  message = ZLocUtils.t("Dialogs","CIP_ToasterRewardText_3");
            }
         }
         genericItemToaster = new TwoIconTitleToasterWindow(messageHeader,message,iconUrl,"","assets/dialogs/FV_BannerAd_Rewards_generic.swf",1,1,new Point(-33,-25));
         ToasterManager.getInstance().togglePause(false);
         ToasterManager.getInstance().add(genericItemToaster);
         StatsManager.count("toaster","view","startnow_reward_granted");
      }
      
      public static function canShowTOS() : Boolean
      {
         return !canShowGDP() || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_START_NOW_GDP) == 6;
      }
      
      public static function canShowGDPAtLevel(level:int) : Boolean
      {
         var result:Boolean = false;
         if(level >= 15)
         {
            if(canShowGDP() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_START_NOW_GDP) == 5)
            {
               result = true;
            }
         }
         return result;
      }
      
      public static function canShowGDPAtSessionCount(sessionCount:int) : Boolean
      {
         var result:Boolean = false;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_START_NOW_GDP);
         if(sessionCount >= 5)
         {
            if(canShowGDP() && variant == 4)
            {
               result = true;
            }
         }
         else if(canShowGDP() && variant == 4)
         {
            sessionCount += 1;
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.CIP_START_NOW,FeatureOptionsManager.CIP_START_NOW_SESSIONS,sessionCount);
            FeatureOptionsManager.getInstance().save();
         }
         return result;
      }
      
      public static function showGDPAtShareCount(shareCount:int) : void
      {
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_START_NOW_GDP);
         if(variant == 1 || variant == 0)
         {
            if(shareCount >= 1)
            {
               if(canShowGDP())
               {
                  CIPStartNow.showStarterPack();
               }
            }
         }
         else if(variant == 3)
         {
            if(shareCount >= 3)
            {
               if(canShowGDP())
               {
                  CIPStartNow.showStarterPack();
               }
            }
         }
      }
   }
}

