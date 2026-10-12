package Transactions
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.LotteryManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconToasterWindow;
   import Widgets.Windows.Lottery.LotteryMainWindow;
   
   public class TLottery extends TFarmTransaction
   {
      
      private static const TOASTER_ICON_PATH:String = "assets/hud/FV_Sweepstakes_HUDicon.png";
      
      public static const TYPE_WINNINGNUMBERS:String = "getWinningNumbers";
      
      public static const TYPE_REDEEMTICKETS:String = "redeemTickets";
      
      public static const TYPE_PURCHASETICKET:String = "purchaseTicket";
      
      public static const TYPE_FETCHNEXTCONFIG:String = "fetchNextConfig";
      
      private var m_transactionType:String;
      
      private var m_extraData:Object;
      
      private var m_callback:Function;
      
      public function TLottery(transactionType:String, extraData:Object = null, callback:Function = null)
      {
         super();
         this.m_transactionType = transactionType;
         this.m_extraData = extraData;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("LotteryService." + this.m_transactionType,this.m_extraData);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var toaster:IconToasterWindow = null;
         var farmItem:FarmItem = null;
         var toaster1:IconToasterWindow = null;
         switch(this.m_transactionType)
         {
            case TYPE_WINNINGNUMBERS:
               if(result.hasOwnProperty("numbers"))
               {
                  LotteryManager.instance.updateWinningNumbers(this.m_extraData["lotteryEnd"],result.numbers);
               }
               break;
            case TYPE_FETCHNEXTCONFIG:
               if(result.hasOwnProperty("config") && result.config != null)
               {
                  LotteryManager.instance.updateConfiguration(result.config);
               }
               if(LotteryManager.instance.mainWindow != null)
               {
                  LotteryManager.instance.mainWindow.close();
                  LotteryManager.instance.queueMainUI();
               }
               break;
            case TYPE_REDEEMTICKETS:
               if(result.hasOwnProperty("cash"))
               {
                  Global.player.cash += result.cash;
                  LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"fc_toaster",LotteryManager.instance.getActiveTickets().length.toString());
                  toaster = new IconToasterWindow(TOASTER_ICON_PATH,ZLocUtils.t("Dialogs","Lottery_ToasterCash",{"totalEarnings":result.cash}));
                  ToasterManager.getInstance().addImmediate(toaster);
               }
               else if(result.hasOwnProperty("item"))
               {
                  farmItem = Global.farmGameSettingsManager.getFarmItemByName(result.item);
                  if(farmItem != null)
                  {
                     Global.player.addGift(farmItem.name);
                     LotteryManager.instance.logLotteryStats(LotteryMainWindow.DIALOG_COUNTER,"consumable_toaster",LotteryManager.instance.getActiveTickets().length.toString());
                     toaster1 = new IconToasterWindow(farmItem.icon,ZLocUtils.t("Dialogs","Lottery_ToasterItem",{"itemName":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName)}));
                     ToasterManager.getInstance().addImmediate(toaster1);
                  }
               }
               LotteryManager.instance.offBoardLottery();
               if(result.hasOwnProperty("config") && result["config"] != null)
               {
                  LotteryManager.instance.updateConfiguration(result.config);
               }
               if(LotteryManager.instance.mainWindow != null)
               {
                  LotteryManager.instance.mainWindow.close();
               }
         }
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

