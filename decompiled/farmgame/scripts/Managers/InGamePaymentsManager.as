package Managers
{
   import Classes.Constants.Experiments;
   import Display.Dialogs.InGamePayment;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Widgets.Windows.BuyMoneyWindow_v2;
   
   public class InGamePaymentsManager
   {
      
      public static const VARIANT_NO_MONEY_ALL:int = 1;
      
      public static const VARIANT_NO_MONEY_1:int = 2;
      
      public static const VARIANT_NO_MONEY_2:int = 3;
      
      public static const VARIANT_NO_MONEY_3:int = 4;
      
      public static const VARIANT_NO_MONEY_STATIC_1:int = 5;
      
      public static const VARIANT_NO_MONEY_STATIC_2:int = 6;
      
      public static const VARIANT_HUD:int = 7;
      
      public static const VARIANT_MARKET:int = 8;
      
      protected static var m_packages:Array = null;
      
      protected static var m_dialog:FarmDynamicDialog = null;
      
      protected static var m_packageBuy:Object = null;
      
      public function InGamePaymentsManager()
      {
         super();
      }
      
      public static function set packages(packages:Array) : void
      {
         m_packages = packages;
      }
      
      public static function get packages() : Array
      {
         return m_packages;
      }
      
      public static function set packageBuy(packageBuy:Object) : void
      {
         m_packageBuy = packageBuy;
      }
      
      public static function get packageBuy() : Object
      {
         return m_packageBuy;
      }
      
      public static function onInGamePaymentEnd(packageCode:String) : void
      {
         var variant:int = 0;
         var stats:String = null;
         if(Boolean(packageCode && packageCode != "" && packageCode != "undefined") && Boolean(Global) && Boolean(Global.experimentManager))
         {
            variant = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
            stats = "Not_enough_cash";
            switch(variant)
            {
               case VARIANT_HUD:
               case VARIANT_MARKET:
                  stats = "Add_cash_payments_test";
            }
            if(m_packageBuy)
            {
               FarmStatsManager.count(stats,"payment_completed",variant.toString(),m_packageBuy["amount"]);
            }
         }
         if(m_dialog != null)
         {
            m_dialog.destroy();
            m_dialog = null;
         }
      }
      
      public static function inNoMoneyFlow() : Boolean
      {
         var variant:int = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
         var inFlow:Boolean = false;
         switch(variant)
         {
            case VARIANT_NO_MONEY_ALL:
            case VARIANT_NO_MONEY_1:
            case VARIANT_NO_MONEY_2:
            case VARIANT_NO_MONEY_3:
            case VARIANT_NO_MONEY_STATIC_1:
            case VARIANT_NO_MONEY_STATIC_2:
               inFlow = true;
         }
         return inFlow;
      }
      
      public static function showInGamePayment(attemptedSpend:int, purchaseName:String = "Other") : void
      {
         var newDialogVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OUTOFCASH_NEW);
         if((m_dialog == null || !m_dialog.isCurrentlyLoading()) && newDialogVariant <= 1)
         {
            onInGamePaymentEnd("");
            m_dialog = FarmDynamicDialog.createDialog("inGamePayment",InGamePayment);
            if(m_dialog is InGamePayment)
            {
               (m_dialog as InGamePayment).m_attemptedSpend = attemptedSpend;
               (m_dialog as InGamePayment).m_purchaseName = purchaseName;
            }
            m_dialog.setup();
            m_dialog.show();
         }
         else
         {
            UI.displayPopup(new BuyMoneyWindow_v2(purchaseName,attemptedSpend),false);
         }
      }
      
      public static function getMinimumPackageSize(attemptedSpend:int) : int
      {
         var offer:Object = null;
         var result:int = 0;
         var biggest:int = 0;
         var moneyNeeded:int = attemptedSpend - Global.player.cash;
         for each(offer in packages)
         {
            if(offer["amount"] >= moneyNeeded)
            {
               if(result == 0 || offer["amount"] < result)
               {
                  result = int(offer["amount"]);
               }
            }
            if(offer["amount"] > biggest)
            {
               biggest = int(offer["amount"]);
            }
         }
         if(0 == result)
         {
            result = biggest;
         }
         return result;
      }
      
      public static function getPaymentNum(attemptedSpend:int = 0) : int
      {
         var size:int = 0;
         var i:* = 0;
         var moneyNeeded:int = 0;
         var num:int = 0;
         var variant:int = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
         switch(variant)
         {
            case 1:
            case 7:
            case 8:
               num = 6;
               break;
            case 5:
            case 6:
               num = 3;
               break;
            case 2:
            case 3:
            case 4:
               num = variant - 1;
               size = int(m_packages.length);
               moneyNeeded = attemptedSpend - Global.player.cash;
               for(i = int(size - 1); i >= 0; i--)
               {
                  if(m_packages[i]["amount"] >= moneyNeeded)
                  {
                     break;
                  }
               }
               if(i - num + 1 <= 0)
               {
                  num += i - num + 1;
               }
         }
         return num;
      }
      
      public static function getPaymentByIndex(index:int) : Object
      {
         var payment:Object = null;
         if(Boolean(m_packages) && m_packages.length > index)
         {
            payment = m_packages[index];
         }
         return payment;
      }
      
      public static function getPayment(index:int, attemptedSpend:int = 0) : Object
      {
         var payment:Object = null;
         var variant:int = 0;
         var offset:int = 0;
         var size:int = 0;
         var i:* = 0;
         var moneyNeeded:int = 0;
         var cell:int = 0;
         variant = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
         switch(variant)
         {
            case VARIANT_NO_MONEY_ALL:
            case VARIANT_HUD:
            case VARIANT_MARKET:
               payment = m_packages[index];
               break;
            case VARIANT_NO_MONEY_STATIC_1:
               payment = m_packages[index * 2];
               break;
            case VARIANT_NO_MONEY_STATIC_2:
               payment = m_packages[index + 1];
               break;
            case VARIANT_NO_MONEY_1:
            case VARIANT_NO_MONEY_2:
            case VARIANT_NO_MONEY_3:
               offset = getPaymentNum(attemptedSpend) + 1 - variant;
               size = int(m_packages.length);
               moneyNeeded = attemptedSpend - Global.player.cash;
               for(i = int(size - 1); i >= 0; i--)
               {
                  if(m_packages[i]["amount"] >= moneyNeeded)
                  {
                     break;
                  }
               }
               offset -= getPaymentNum(attemptedSpend) - 1;
               if(i + offset < 0)
               {
                  offset -= i + offset;
               }
               cell = index + i + offset;
               payment = m_packages[cell];
         }
         return payment;
      }
   }
}

