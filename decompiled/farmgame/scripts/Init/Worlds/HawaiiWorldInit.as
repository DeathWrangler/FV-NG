package Init.Worlds
{
   import Classes.Idle.GenericToasterIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.ZItem.FarmItem;
   import Classes.util.CurrencyConversionUtil;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.QueuedIcon;
   import Display.UI;
   import Events.FarmGameWorldEvent;
   import Init.PostInitActionHandlers.PostInitFunctionCall;
   import Init.PostInitActionHandlers.RightSideHUDIconInitAction;
   import Managers.AnimalSanctuaryManager;
   import Managers.ToasterManager;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class HawaiiWorldInit extends HomeWorldInit
   {
      
      public static const HAWAII_COCO_RIGHT_HUD_ICON_NAME:String = "CocoIcon";
      
      public function HawaiiWorldInit()
      {
         super();
      }
      
      override public function onEnterWorld(resultData:Object) : void
      {
         super.onEnterWorld(resultData);
         Global.postInitActionsManager.addInitAction(new PostInitFunctionCall(this.displayCurrencyToaster));
         Global.postInitActionsManager.addInitAction(new RightSideHUDIconInitAction(QueuedIcon.ICON_CODE_COCONUTS));
         if(Boolean(AnimalSanctuaryManager.getInstance()) && AnimalSanctuaryManager.getInstance().isFeatureActive)
         {
            if(Global.player.postInitFinished)
            {
               AnimalSanctuaryManager.getInstance().setupCasablancaHud();
            }
            else
            {
               Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud,false,0,true);
            }
         }
      }
      
      private function displayCurrencyToaster() : void
      {
         var miniMarketItems:Array = null;
         var titleText:String = null;
         var messageText:String = null;
         var cbSetFreq:Function = null;
         var cbDisplayMiniMarket:Function = null;
         var toaster:TwoIconTitleToasterWindow = null;
         var currencyExchangeItems:Array = Global.farmGameSettingsManager.getFarmItemsArrayByType("aide","othercurrency_exchange");
         var currencyExchangeItem:FarmItem = null;
         var currencyExchangeItemsLength:int = int(currencyExchangeItems.length);
         miniMarketItems = [];
         for each(currencyExchangeItem in currencyExchangeItems)
         {
            if(null != currencyExchangeItem && CurrencyConversionUtil.isCurrencyExchangeItem(currencyExchangeItem.name))
            {
               if(CurrencyConversionUtil.isValidCurrencyExchangeItem(currencyExchangeItem.name,Global.worldManager.currentWorldCurrency))
               {
                  miniMarketItems.push(currencyExchangeItem.name);
               }
            }
         }
         titleText = ZLocUtils.t("Dialogs","HawaiiBuyCoconutsToaster_Title");
         messageText = ZLocUtils.t("Dialogs","HawaiiBuyCoconutsToaster_text");
         cbSetFreq = function(event:Event):void
         {
            event.target.removeEventListener(ToasterManager.DISPLAYED_EVENT,cbSetFreq);
            Global.player.setFeatureLastShown("HawaiiCoconutsToasterLastSeen",GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         };
         cbDisplayMiniMarket = function(e:MouseEvent):void
         {
            if(miniMarketItems.length > 0)
            {
               UI.displayMiniMarketDialog(miniMarketItems);
            }
         };
         toaster = new TwoIconTitleToasterWindow(titleText,messageText,"assets/trees/tree_coconut_icon.png","","assets/dialogs/FV_BannerAd_Rewards_generic_hawaii.swf",0.5,0.5,new Point(15,8),new Point(15,0),cbDisplayMiniMarket);
         toaster.addEventListener(ToasterManager.DISPLAYED_EVENT,cbSetFreq);
         IdleTaskQueue.getInstance().addTask(new GenericToasterIdleTask(toaster,5000,"HawaiiBuyCoconutsToaster"));
      }
      
      private function deferredsetupHud(e:Event = null) : void
      {
         if(Global.player.postInitFinished)
         {
            Global.world.removeEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.deferredsetupHud);
            if(AnimalSanctuaryManager.getInstance())
            {
               AnimalSanctuaryManager.getInstance().setupCasablancaHud();
            }
         }
      }
      
      override public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         Global.hud.rightSideIconQueue.removeIconByName(HAWAII_COCO_RIGHT_HUD_ICON_NAME);
         super.onLeaveWorld(destIsVisiting);
         if(Global.hud)
         {
            Global.hud.removeBottomHudCasablancaInnovationButton();
         }
      }
   }
}

