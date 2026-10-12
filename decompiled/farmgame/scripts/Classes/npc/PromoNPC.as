package Classes.npc
{
   import Classes.NPC;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import GameMode.GameMode;
   import Managers.FarmStatsManager;
   import Managers.NPCManager;
   import Widgets.Windows.Promotions.BrandedPromoHelpAndShareWindow;
   import Widgets.Windows.Promotions.BrandedPromoHelpWindow;
   import Widgets.Windows.Promotions.BrandedPromoRewardWindow;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class PromoNPC extends NPC
   {
      
      protected static var m_isLoaded:Boolean;
      
      public static const ACTION_URL:String = "URL";
      
      private var m_newWorld:Object = null;
      
      private var m_dialogTimer:Timer;
      
      protected var m_npcName:String;
      
      protected var m_npcStat:String;
      
      public function PromoNPC(npcid:String, NPCname:String, npcConfigData:Object)
      {
         super(npcid,npcConfigData);
         this.m_npcName = NPCname;
         if(npcConfigData.stat)
         {
            this.m_npcStat = npcConfigData.stat;
         }
         Global.worldManager.npcClickEnabled = npcConfig.allowclickactions == "true" ? true : false;
      }
      
      override public function beginVisitAction(aid:int = -1) : void
      {
         if(m_npcData.stat)
         {
            FarmStatsManager.count(m_npcData.stat,"neighborbar_clicks");
         }
         super.beginVisitAction(aid);
         if(!PromoNPC.m_isLoaded && Boolean(this.m_dialogTimer))
         {
            this.m_dialogTimer.start();
         }
         PromoNPC.m_isLoaded = true;
      }
      
      override public function addAction(aid:int) : void
      {
         this.m_dialogTimer = new Timer(Global.farmGameSettingsManager.getInt(this.m_npcName + "PromoDialogsDelay",3000));
         this.m_dialogTimer.addEventListener(TimerEvent.TIMER,this.onDialogTimer);
         if(PromoNPC.m_isLoaded)
         {
            this.m_dialogTimer.start();
         }
      }
      
      private function onDialogTimer(e:TimerEvent) : void
      {
         var acceptAction:String = null;
         var assetPath:String = "";
         if(!m_helpedFarm)
         {
            this.m_dialogTimer.stop();
            if(npcConfig.usehelpsharepoponly == "true")
            {
               if(NPCManager.getInstance().isVisitingNPC)
               {
                  assetPath = Global.farmGameSettingsManager.getString("promoFarmPopupStart_" + this.m_npcName);
                  if("" != assetPath)
                  {
                     UI.displayPopup(new BrandedPromoHelpAndShareWindow(m_npcData.name,this.onVisitDialogClose,this.onCloseRewardDialog,assetPath));
                     FarmStatsManager.count(m_npcData.stat,"helpdialog_impression");
                  }
               }
            }
            else if(NPCManager.getInstance().isVisitingNPC)
            {
               assetPath = Global.farmGameSettingsManager.getString("promoFarmPopupStart_" + this.m_npcName);
               if("" != assetPath)
               {
                  UI.displayPopup(new BrandedPromoHelpWindow(m_npcData.name,this.onVisitDialogClose,assetPath));
                  FarmStatsManager.count(m_npcData.stat,"helpdialog_impression");
               }
            }
         }
         else
         {
            this.m_dialogTimer.removeEventListener(TimerEvent.TIMER,this.onDialogTimer);
            this.m_dialogTimer.stop();
            this.m_dialogTimer = null;
            assetPath = Global.farmGameSettingsManager.getString("promoFarmPopupEnd_" + this.m_npcName);
            if("" != assetPath)
            {
               acceptAction = Global.farmGameSettingsManager.getString("promoFarmPopupEnd_" + this.m_npcName + "_action");
               UI.displayPopup(new BrandedPromoRewardWindow(m_npcData.name,this.onCloseRewardDialog,assetPath,acceptAction));
               FarmStatsManager.count(m_npcData.stat,"thanksdialog_impression");
            }
         }
      }
      
      public function onVisitDialogClose(isAccept:Boolean) : void
      {
         if(isAccept)
         {
            m_helpedFarm = true;
            this.onActionSuccess(this.m_actionsAvailable.shift(),this.setWorldFromBackend);
            this.m_actionsAvailable.pop();
         }
      }
      
      public function setWorldFromBackend(result:Object) : void
      {
         this.m_newWorld = result.world;
         if(result.rewardData)
         {
            m_rewardData = result.rewardData;
         }
         var outsideOverlay:String = Global.farmGameSettingsManager.getString("backgroundOverlay_" + this.m_npcName);
         if(outsideOverlay != null)
         {
            this.m_newWorld.outsideOverlay = outsideOverlay;
         }
         this.onFinishAction();
      }
      
      private function onFinishAction() : void
      {
         var giftItem:Object = null;
         var currentGM:GameMode = null;
         var quantity:int = 0;
         if(this.m_newWorld)
         {
            currentGM = Global.world.getTopGameMode();
            Global.world.cleanup();
            Global.world.loadObject(this.m_newWorld);
            Global.world.addGameMode(currentGM);
            if(Global.player.avatar)
            {
               Global.world.addPlayerAvatar(Global.player.avatar);
               Global.selectedAvatar = Global.player.avatar;
            }
         }
         this.m_dialogTimer.stop();
         this.m_dialogTimer = null;
         this.m_dialogTimer = new Timer(Global.farmGameSettingsManager.getInt(this.m_npcName + "PromoRewardDialogsDelay",10000));
         this.m_dialogTimer.addEventListener(TimerEvent.TIMER,this.onDialogTimer);
         this.m_dialogTimer.start();
         for each(giftItem in m_rewardData)
         {
            quantity = 1;
            if(giftItem.quantity)
            {
               quantity = int(giftItem.quantity);
            }
            Global.player.addGift(giftItem.itemName,"0",quantity);
         }
      }
      
      public function onCloseRewardDialog(isAccept:Boolean, action:String = "") : void
      {
         var rewardUrl:String = null;
         if(isAccept)
         {
            switch(action)
            {
               case ACTION_URL:
                  FarmStatsManager.count(this.m_npcStat,"url","visit");
                  rewardUrl = Global.farmGameSettingsManager.getString("promoFarmRewardURL_" + this.m_npcName);
                  if(ZLocUtils.hasString("Dialogs","promoFarmRewardURL_" + this.m_npcName))
                  {
                     rewardUrl = ZLocUtils.t("Dialogs","promoFarmRewardURL_" + this.m_npcName,{"uid":Global.player.thirdPartyID});
                  }
                  FarmGameUtil.launchURL(rewardUrl,"_blank",null,true);
                  break;
               default:
                  if(Boolean(this.m_npcData) && Boolean(this.m_npcData.id))
                  {
                     NPCManager.getInstance().launchShareFeed(this.m_npcData.id);
                  }
            }
         }
      }
      
      public function onWorldReplaced(event:Event) : void
      {
         this.onFinishAction();
      }
   }
}

