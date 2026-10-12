package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LESlotMachine.LESlotMachineSlotFrame;
   import Widgets.Slots.LESlotMachine.LESlotMachineDiscountSlot;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public final class LESlotMachineWindow extends FarmWindow
   {
      
      public static const EXPERIMENT_NAME:String = "fv_wheel_bundles_2";
      
      public static const DIALOG_ASSET:String = "assets/dialogs/FV_FortuneWheel.swf";
      
      private static const SPIN_AUTO_STOP_DELAY:int = 5000;
      
      private static const OPTION_NUM_SPINS:String = "numspins";
      
      private static const OPTION_LAST_BUNDLES_SPUN:String = "lastbundlesspun";
      
      private static const OPTION_BOUGHT_LAST_BUNDLE:String = "boughtlastbundle";
      
      public static var Y_OFFSET:int = 210;
      
      public static const MISS_ITEM_NAME:String = "SAD_COW";
      
      public static const FILLER_ITEM_NAME:String = "horse";
      
      private static const FILLER_ITEM_LIST:Array = ["cow_disco","cow_fanpage","cow_yellowpatch","cow_pinkpatch","holidaytree","lychee","treeswing","treehousefall","cottoncandy","maple","planterround","hatplanter","stockingplanter","camel","birdfountain","birdofparadise","horse_prz","horse_saddled","pony_purple","deer_white","restingdogrock","dogsled","dogrose","dog_grapeshaptag","adobevacationhome","cat_sphynx","bunnypeek","icebunny","palmmonster","chicken_super","chicken_candycane","goat_nigeriandwarf","saloon","poolhouse","wedding","easterbasket","mexicobeach","swissmountain","swissbarn","tuscanyvilla","marvinvillagecenter","turbo_charger_3pack","consume_instant_grow_flight","pkg_coins_1000","fuelalaska","rabbit_arctic","rabbit_newyear","goose_grey","spooky_battree","mardigras","clementine","redflamingo","roseyellow","wildflowerpond","carnationpink","poinsettia","lupine","hellebore","hollyhock","lotus"];
      
      public const NUM_SLOT_REELS:int = 3;
      
      public const NUM_INIT_SPINS:int = 3;
      
      private var m_buySpinFrame:ZwFrame = null;
      
      private var m_spinsRemainingFrame:ZwFrame = null;
      
      private var m_stopButton:FarmAnimatedTextButton = null;
      
      private var m_purchaseButton:FarmAnimatedTextButton = null;
      
      private var m_spinButton:FarmAnimatedTextButton = null;
      
      private var m_slotsContainer:LESlotMachineSlotFrame = null;
      
      private var m_discountSlot:LESlotMachineDiscountSlot = null;
      
      private var m_originalPriceText:ZwTextField = null;
      
      private var m_discountPriceText:ZwTextField = null;
      
      private var m_buyXItemsText:ZwTextField = null;
      
      private var m_buySpinPriceText:ZwTextField = null;
      
      private var m_buySpinButton:FarmAnimatedTextButton = null;
      
      private var m_spinAmountText:ZwTextField = null;
      
      private var m_spinTimer:Timer = null;
      
      private var m_showBuySpin:Boolean = false;
      
      private var m_congratsPopup:ZwFrame = null;
      
      private var m_bulbBorder:ZwFrame = null;
      
      private const BULB_WIN_INDEX:int = 0;
      
      private const BULB_IDLE_INDEX:int = 1;
      
      private const BULB_START_INDEX:int = 2;
      
      public function LESlotMachineWindow()
      {
         super(DIALOG_ASSET);
      }
      
      override protected function postLoadComplete() : void
      {
         this.m_buySpinFrame = addWidget(new ZwFrame(m_window.spinsBuy_mc)) as ZwFrame;
         this.m_buySpinButton = this.m_buySpinFrame.addWidget(new FarmAnimatedTextButton(this.m_buySpinFrame.element.buyspin_bt,ZLocUtils.t("Dialogs","LESlotMachine_buySpin"),this.onBuySpin),true) as FarmAnimatedTextButton;
         this.m_buySpinPriceText = this.m_buySpinFrame.addWidget(new ZwTextField(this.m_buySpinFrame.element.amount_tf,"amount_tf"),true) as ZwTextField;
         var lastBundlesSpun:Array = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_LAST_BUNDLES_SPUN) as Array;
         var slotValues:Array = ["cow","cow","cow"];
         var discountValue:Number = 0;
         if(lastBundlesSpun != null && lastBundlesSpun.length > 0)
         {
            slotValues = lastBundlesSpun[0]["items"];
            discountValue = Number(lastBundlesSpun[0]["discount"]);
         }
         var slotStartingValues:Array = this.generateSlotResultsItems(slotValues);
         var discountStartingValues:Array = [11,20,33,44,55,66,77];
         this.m_slotsContainer = addWidget(new LESlotMachineSlotFrame(m_window.slots_mc,slotStartingValues)) as LESlotMachineSlotFrame;
         this.m_discountSlot = addWidget(new LESlotMachineDiscountSlot(m_window.discount_mc)) as LESlotMachineDiscountSlot;
         this.m_discountSlot.repopulatePanels(this.generateSlotResultsDiscount(discountValue));
         this.m_congratsPopup = addWidget(new ZwFrame(m_window.congrats_mc)) as ZwFrame;
         this.m_bulbBorder = addWidget(new ZwFrame(m_window.bulbBorder_start_mc)) as ZwFrame;
         this.m_spinsRemainingFrame = addWidget(new ZwFrame(m_window.spins_mc)) as ZwFrame;
         this.m_spinAmountText = this.m_spinsRemainingFrame.addWidget(new ZwTextField(this.m_spinsRemainingFrame.element.counter_tf,"counter_tf"),true) as ZwTextField;
         this.m_spinsRemainingFrame.addWidget(new ZwTextField(this.m_spinsRemainingFrame.element.generic_tf,ZLocUtils.t("Dialogs","LESlotMachine_spinsLeft")),true);
         this.m_stopButton = addWidget(new FarmAnimatedTextButton(m_window.stop_bt,ZLocUtils.t("Dialogs","LESlotMachine_stop"),this.onStop),true) as FarmAnimatedTextButton;
         this.m_purchaseButton = addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","Buy"),this.onPurchaseBundle),true) as FarmAnimatedTextButton;
         this.m_spinButton = addWidget(new FarmAnimatedTextButton(m_window.spin_bt,ZLocUtils.t("Dialogs","LESlotMachine_spin"),this.onSpin),true) as FarmAnimatedTextButton;
         addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","LESlotMachine_subTitle")),true);
         this.m_buyXItemsText = addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","LESlotMachine_buyXItems",{"numItems":this.getNumItemsSpun().toString()})),true) as ZwTextField;
         this.m_discountPriceText = addWidget(new ZwTextField(m_window.amount_tf,"amount_tf"),true) as ZwTextField;
         this.m_originalPriceText = addWidget(new ZwTextField(m_window.amount1_tf,"amount1_tf"),true) as ZwTextField;
         this.m_spinTimer = new Timer(SPIN_AUTO_STOP_DELAY,1);
         this.refreshLayout();
         this.flashBulbs(this.BULB_IDLE_INDEX);
         super.postLoadComplete();
      }
      
      override protected function onClose(event:Event) : void
      {
         CarnivalBoothWindow.promoteCarnivalBooth();
         super.onClose(event);
      }
      
      override public function getDialogOffset() : Point
      {
         return new Point(0,Y_OFFSET);
      }
      
      public function flashBulbs(stateIndex:int) : void
      {
         switch(stateIndex)
         {
            case this.BULB_IDLE_INDEX:
               (this.m_bulbBorder.element as MovieClip).gotoAndStop(1);
               break;
            case this.BULB_START_INDEX:
               (this.m_bulbBorder.element as MovieClip).gotoAndPlay(2);
               break;
            case this.BULB_WIN_INDEX:
               (this.m_bulbBorder.element as MovieClip).gotoAndPlay(30);
         }
      }
      
      protected function refreshLayout() : void
      {
         var spins:int = int(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_NUM_SPINS));
         var boughtLastBundle:Boolean = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_BOUGHT_LAST_BUNDLE) as Boolean;
         var lastBundlesSpun:Array = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_LAST_BUNDLES_SPUN) as Array;
         if(spins <= 0)
         {
            this.m_showBuySpin = true;
         }
         this.m_buySpinFrame.visible = this.m_showBuySpin;
         this.toggleButton(this.m_purchaseButton,!boughtLastBundle && lastBundlesSpun != null && lastBundlesSpun.length > 0);
         this.toggleButton(this.m_spinButton,spins != 0);
         this.toggleButton(this.m_buySpinButton,spins < 9 && Global.player.gold > this.getSpinPrice());
         this.toggleButton(this.m_stopButton,false);
         this.m_spinAmountText.text = spins.toString();
         this.m_buySpinPriceText.text = this.getSpinPrice().toString();
         this.m_discountPriceText.text = this.calculateBundlePrice(true).toString();
         this.m_originalPriceText.text = this.calculateBundlePrice(false).toString();
         var numItems:int = this.getNumItemsSpun();
         if(numItems > 1)
         {
            this.m_buyXItemsText.text = ZLocUtils.t("Dialogs","LESlotMachine_buyXItems",{"numItems":numItems.toString()});
         }
         else
         {
            this.m_buyXItemsText.text = ZLocUtils.t("Dialogs","LESlotMachine_buy1Item");
         }
      }
      
      protected function onSpin(event:Event) : void
      {
         var numSpinsRemaining:int = this.NUM_INIT_SPINS;
         if(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_NUM_SPINS) != null)
         {
            numSpinsRemaining = int(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_NUM_SPINS));
         }
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_NUM_SPINS,numSpinsRemaining - 1);
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_BOUGHT_LAST_BUNDLE,false);
         this.refreshLayout();
         this.toggleButton(this.m_spinButton,false);
         this.toggleButton(this.m_purchaseButton,false);
         this.toggleButton(this.m_stopButton,false);
         this.toggleButton(this.m_buySpinButton,false);
         this.toggleButton(m_closeButton,false);
         this.flashBulbs(this.BULB_START_INDEX);
         this.m_slotsContainer.startSpin();
         this.m_discountSlot.spinStart();
         TransactionManager.addTransaction(new TGenericTransaction("LESlotMachineService","spin",this.onSpinReturned),true);
      }
      
      private function toggleButton(btn:FarmButton, enabled:Boolean) : void
      {
         btn.enabled = enabled;
         btn.applyGrayOut = !enabled;
      }
      
      protected function onSpinReturned(result:Object) : void
      {
         this.m_slotsContainer.repopulateData(this.generateSlotResultsItems(result["items"]));
         this.m_discountSlot.repopulatePanels(this.generateSlotResultsDiscount(result["discount"]));
         this.m_spinTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onSpinnerTimeout);
         this.m_spinTimer.start();
         this.toggleButton(this.m_stopButton,true);
         var lastBundlesSpun:Array = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_LAST_BUNDLES_SPUN) as Array;
         if(lastBundlesSpun == null)
         {
            lastBundlesSpun = [];
         }
         while(lastBundlesSpun.length >= 3)
         {
            lastBundlesSpun.pop();
         }
         lastBundlesSpun.unshift(result);
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_LAST_BUNDLES_SPUN,lastBundlesSpun);
      }
      
      protected function getNumItemsSpun() : int
      {
         var name:String = null;
         var result:int = this.NUM_SLOT_REELS;
         var lastBundlesSpun:Array = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_LAST_BUNDLES_SPUN) as Array;
         if(lastBundlesSpun != null && lastBundlesSpun.length > 0)
         {
            result = 0;
            for each(name in lastBundlesSpun[0]["items"])
            {
               if(name != null && name != MISS_ITEM_NAME)
               {
                  result++;
               }
            }
         }
         return result;
      }
      
      protected function getQuantityOfItems() : Array
      {
         var itemBundle:Array = null;
         var i:int = 0;
         var item:FarmItem = null;
         var itemPackageCount:int = 0;
         var result:Array = [1,1,1];
         var lastBundlesSpun:Array = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_LAST_BUNDLES_SPUN) as Array;
         if(lastBundlesSpun != null && lastBundlesSpun.length > 0)
         {
            itemBundle = lastBundlesSpun[0]["items"];
            for(i = 0; i < this.NUM_SLOT_REELS; i++)
            {
               if(itemBundle[i] != null && itemBundle[i] != MISS_ITEM_NAME)
               {
                  item = Global.farmGameSettingsManager.getFarmItemByName(itemBundle[i]);
                  itemPackageCount = 0;
                  if(item != null)
                  {
                     if(FarmGameSettingsManager.isInDataSourceExperiment())
                     {
                        itemPackageCount = item.getIntFromDataSource("itemPackage","amount");
                     }
                     else if(item.xml.itemPackage != null && item.xml.itemPackage.amount != null)
                     {
                        itemPackageCount = int(item.xml.itemPackage.amount);
                     }
                     if(item.count > 1)
                     {
                        result[i] = item.count;
                     }
                     else if(itemPackageCount != 0)
                     {
                        result[i] = itemPackageCount;
                     }
                  }
               }
               else
               {
                  result[i] = 0;
               }
            }
         }
         return result;
      }
      
      protected function generateSlotResultsItems(results:Array) : Array
      {
         var k:int = 0;
         for(var i:int = 0; i < this.NUM_SLOT_REELS; i++)
         {
            if(results[i] == null)
            {
               results[i] = MISS_ITEM_NAME;
            }
         }
         var slots:Array = [[FILLER_ITEM_NAME,results[0],FILLER_ITEM_NAME,FILLER_ITEM_NAME,FILLER_ITEM_NAME,results[0]],[FILLER_ITEM_NAME,results[1],FILLER_ITEM_NAME,FILLER_ITEM_NAME,FILLER_ITEM_NAME,results[1]],[FILLER_ITEM_NAME,results[2],FILLER_ITEM_NAME,FILLER_ITEM_NAME,FILLER_ITEM_NAME,results[2]]];
         for(i = 0; i < this.NUM_SLOT_REELS; i++)
         {
            for(k = 0; k < 6; k++)
            {
               slots[i][k] = FILLER_ITEM_LIST[int(Math.round(Math.random() * (FILLER_ITEM_LIST.length - 1)))];
            }
         }
         for(i = 0; i < this.NUM_SLOT_REELS; i++)
         {
            slots[i].push(slots[i][0]);
            slots[i].push(slots[i][1]);
            slots[i][1] = slots[i][5] = results[i];
         }
         return slots;
      }
      
      protected function generateSlotResultsDiscount(result:Number) : Array
      {
         var randomNum:int = 0;
         var resultAsInt:int = int(result * 100);
         var slots:Array = [];
         while(slots.length < 6)
         {
            randomNum = Math.ceil(Math.random() * 10) * 5;
            slots.push(randomNum);
         }
         slots.push(slots[0]);
         slots.push(slots[1]);
         slots[5] = resultAsInt;
         return slots;
      }
      
      protected function onSpinnerTimeout(event:TimerEvent) : void
      {
         this.onStop(null);
         this.m_spinTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onSpinnerTimeout);
      }
      
      protected function onStop(event:Event) : void
      {
         if(this.m_spinTimer)
         {
            this.m_spinTimer.reset();
         }
         this.m_slotsContainer.stopSpin();
         this.m_discountSlot.spinStopSchedule(3000,this.onSpinStopped);
         this.toggleButton(this.m_stopButton,false);
      }
      
      protected function onSpinStopped() : void
      {
         this.refreshLayout();
         this.flashBulbs(this.BULB_WIN_INDEX);
         this.toggleButton(m_closeButton,true);
      }
      
      private function calculateBundlePrice(discounted:Boolean = true) : int
      {
         var totalPrice:Number = NaN;
         var name:String = null;
         var item:FarmItem = null;
         var cashValue:Number = NaN;
         var result:int = 0;
         var lastBundlesSpun:Array = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_LAST_BUNDLES_SPUN) as Array;
         if(lastBundlesSpun != null && lastBundlesSpun.length > 0)
         {
            totalPrice = 0;
            for each(name in lastBundlesSpun[0]["items"])
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(name);
               if(item != null && item.cash > 0)
               {
                  cashValue = item.cash;
                  if(discounted)
                  {
                     cashValue *= 1 - lastBundlesSpun[0]["discount"];
                     cashValue = Math.round(cashValue);
                  }
                  totalPrice += cashValue;
               }
            }
            result = int(totalPrice);
         }
         return result;
      }
      
      protected function onPurchaseBundle(event:Event) : void
      {
         var lastBundlesSpun:Array = null;
         var name:String = null;
         var item:FarmItem = null;
         var price:int = this.calculateBundlePrice();
         if(Global.player.canBuyCash(price,true,"LESlotMachineBundle"))
         {
            Global.player.cash -= price;
            lastBundlesSpun = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_LAST_BUNDLES_SPUN) as Array;
            for each(name in lastBundlesSpun[0]["items"])
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(name);
               if(item != null)
               {
                  Global.player.addGift(name);
               }
            }
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_BOUGHT_LAST_BUNDLE,true);
            TransactionManager.addTransaction(new TGenericTransaction("LESlotMachineService","purchaseBundle"));
            this.refreshLayout();
            this.flashBulbs(this.BULB_IDLE_INDEX);
            (this.m_congratsPopup.element as MovieClip).gotoAndPlay(2);
         }
      }
      
      private function getSpinPrice() : int
      {
         var price:int = 25000;
         var variant:int = Global.experimentManager.getExperimentVariant(LESlotMachineWindow.EXPERIMENT_NAME);
         switch(variant)
         {
            case 2:
            case 4:
               price = 15000;
               break;
            case 6:
            case 7:
               price = 50000;
               break;
            case 8:
            case 9:
               price = 100000;
               break;
            case 3:
            case 5:
            default:
               price = 25000;
         }
         return price;
      }
      
      protected function onBuySpin(event:Event) : void
      {
         var numSpinsRemaining:int = this.NUM_INIT_SPINS;
         if(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_NUM_SPINS) != null)
         {
            numSpinsRemaining = int(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_NUM_SPINS));
         }
         Global.player.gold -= this.getSpinPrice();
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.LE_SLOT_MACHINE,OPTION_NUM_SPINS,numSpinsRemaining + 1);
         this.refreshLayout();
         TransactionManager.addTransaction(new TGenericTransaction("LESlotMachineService","buySpin"));
      }
   }
}

