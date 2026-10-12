package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.feed.GenericRewardFeed;
   import Classes.util.FarmGameUtil;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class SpecialLEBundleWindow extends FarmWindow
   {
      
      private static const OPEN_UI_DELAY:int = 3200;
      
      private static const SERVICE_NAME:String = "LEBundleGrantService";
      
      private static const SERVICE_FUNC_GRANT_BONUS:String = "grantLEBundle";
      
      private var m_windowCloseButton:FarmButton;
      
      private var m_item:Object;
      
      private var m_timer:Timer;
      
      private var m_acceptBt:FarmAnimatedTextButton;
      
      private var LE_BUNDLE_CASH_PRICE:int = 99;
      
      private var m_rewardWindow:GenericSingleRewardPopup;
      
      private var BUNDLE_BONUS1_ID:String = "LEBundle_BragFeed";
      
      private var LE_BUNDLE_ITEMS:Array = new Array("magicdeer_bloominglovedreamdeer","layeredcyrstalhearttree","heartdewdropstree","pegacorn_jeweledfaberge","chicken_glitterpinkheart","swan_royalgoldvalentine","royalheartcarriage","jeweledheartcrowntree","crystalheartwingtree","goldenheartbursttree","foreverloveheart","valentineprincessgnome","keyandjeweledhearttree","unicorn_royaljuliet","pegacorn_goldencupid");
      
      private var m_leBundleItems_mc:MovieClip;
      
      private var m_access:String = "";
      
      private var m_featureEndTimer:ZwTextField;
      
      public function SpecialLEBundleWindow(assetPath:String = "", access:String = "HUD")
      {
         super(assetPath);
         this.m_access = access;
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var itemNameTooltip:ZwWidget = null;
         var item:FarmItem = null;
         super.postLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.mainWindow))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            addWidget(new ZwTextField(m_window["mainWindow"]["body_tf"],"All for one price!"));
            addWidget(new ZwTextField(m_window["mainWindow"]["title_tf"],"Bundle of Love"));
            addWidget(new ZwTextField(m_window["mainWindow"]["percent_tf"],"55%"));
            addWidget(this.m_featureEndTimer = new ZwTextField(m_window["mainWindow"]["body2_tf"],""));
            addWidget(this.m_acceptBt = new FarmAnimatedTextButton(m_window["mainWindow"]["accept_bt"],"Buy Now",this.onAccept));
            addWidget(new ZwTextField(m_window["mainWindow"]["accept_bt"]["amount_tf"],"99"));
            addWidget(new ZwTextField(m_window["mainWindow"]["accept_bt"]["amount_full_tf"],"235"));
            this.m_windowCloseButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose)) as FarmButton;
            for(i = 0; i < this.LE_BUNDLE_ITEMS.length; i++)
            {
               itemNameTooltip = new ZwWidget(m_window["mainWindow"]["asset" + i.toString() + "_mc"]);
               this.m_leBundleItems_mc = m_window["mainWindow"]["asset" + i.toString() + "_mc"] as MovieClip;
               MovieClipUtils.recursivePlay(this.m_leBundleItems_mc);
               item = Global.farmGameSettingsManager.getFarmItemByName(this.LE_BUNDLE_ITEMS[i]);
               if(item)
               {
                  itemNameTooltip.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(item.friendlyName)));
               }
            }
            UI.stopPopups(true);
            this.startTimer();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         this.stopTimer();
         untintWindow();
         UI.stopPopups(false);
         FarmStatsManager.count("LE_Bundle",this.m_access,"","closes",Global.worldManager.currentWorldType,"LE_Bundle");
         close();
      }
      
      private function onAccept(event:Event) : void
      {
         var confirmationText:String = "Are you sure you want to buy the Bundle of Love?";
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
            this.m_acceptBt.enabled = false;
            m_window.enableInput = false;
            tintWindow();
         }
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onClickSkipButtonAfterConfirmation(event);
         }
         else
         {
            this.m_acceptBt.enabled = true;
            untintWindow();
            m_window.enableInput = true;
         }
         FarmStatsManager.count("fv_cash_buy_LE","LE_Bundle",this.m_access,"99",Global.worldManager.currentWorldType,"LE_Bundle");
         if(this.m_access == "MOTD")
         {
            FarmStatsManager.count("LE_Bundle","MOTD","","buy",Global.worldManager.currentWorldType,"");
         }
      }
      
      private function onClickSkipButtonAfterConfirmation(event:Event) : void
      {
         var item:FarmItem = null;
         if(Global.player.canBuyCash(this.LE_BUNDLE_CASH_PRICE))
         {
            Global.player.cash -= this.LE_BUNDLE_CASH_PRICE;
            Global.player.addGift("consume_lebundle_pack_v9");
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_GRANT_BONUS,null),true);
            UI.stopPopups(false);
            item = Global.farmGameSettingsManager.getFarmItemByName("consume_lebundle_pack_v9");
            this.m_rewardWindow = new GenericSingleRewardPopup("assets/dialogs/FV_LEBundle_Feb2020/FV_Feb_LEBundle2020_prize.swf","LEBundle",item,this.onButtonClick);
            UI.displayPopup(this.m_rewardWindow,false);
            this.onClose(event);
         }
         else
         {
            untintWindow();
            m_window.m_enableInput = true;
         }
      }
      
      override protected function release() : void
      {
         this.m_windowCloseButton = null;
         super.release();
      }
      
      public function onButtonClick(event:Event) : void
      {
         new GenericRewardFeed("consume_lebundle_pack_v9",this.BUNDLE_BONUS1_ID).shareFeed();
         untintWindow();
         this.m_rewardWindow.close();
         this.onClose(event);
      }
      
      public function getTimeLeft() : Number
      {
         var endDate:String = "2/16/2020";
         var featureExpiredTime:Number = FarmGameUtil.synchronizedDateTimeToNumber(endDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return featureExpiredTime - currenttime;
      }
      
      private function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeLeft:Number = this.getTimeLeft();
         if(this.m_featureEndTimer)
         {
            if(timeLeft < 0)
            {
               this.m_featureEndTimer.text = "This Bundle has expired";
               this.m_acceptBt.visible = false;
            }
            else
            {
               this.m_featureEndTimer.text = "Bundle ends in " + HUD.getformattedTimeLeft(timeLeft);
            }
         }
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
   }
}

