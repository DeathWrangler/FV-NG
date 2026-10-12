package Display
{
   import Classes.EvolutionAnimal;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.EvolutionManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Icons.FarmItemIcon;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class EvolutionDialog extends Dialog
   {
      
      private static const NUM_ANIMAL_SLOTS:int = 10;
      
      private static const ALPHA_VALUE:Number = 0.35;
      
      private var m_animal:EvolutionAnimal;
      
      private var m_slotToAnimalMapping:Array;
      
      private var m_slotFrames:MovieClip;
      
      private var m_feedSlot:MovieClip;
      
      private var m_feedBuyBtn:FarmAnimatedCashButton;
      
      private var m_completeBtn:FarmAnimatedCashButton;
      
      private var m_feedAskBtn:FarmAnimatedButton;
      
      private var m_feedUseBtn:FarmAnimatedButton;
      
      private var m_crateSlot:MovieClip;
      
      private var m_crateBuyBtn:FarmAnimatedCashButton;
      
      private var m_animalFrames:MovieClip;
      
      private var m_closeBtn:SimpleButton;
      
      private var m_whatisthisBtn:GenericButton;
      
      private var m_isShowing:Boolean = false;
      
      private var m_windowTitle:ZwTextField;
      
      private var m_data:Object;
      
      private var m_elderString:ZwTextField;
      
      public function EvolutionDialog(dialogAsset:String, animal:EvolutionAnimal)
      {
         m_dialogAsset = dialogAsset;
         this.m_animal = animal;
         super();
         this.m_slotToAnimalMapping = EvolutionManager.instance.getBlueAnimals();
         if(!this.isAnimalInArray(animal.getItemName(),this.m_slotToAnimalMapping))
         {
            this.m_slotToAnimalMapping = EvolutionManager.instance.getPinkAnimals();
         }
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.initDialog();
         this.setupItemSlots();
         this.setupAnimalSlots();
         this.m_isShowing = true;
      }
      
      public function initDialog() : void
      {
         this.m_data = EvolutionManager.instance.getFeatureData();
         if(m_window.close_bt)
         {
            this.m_closeBtn = m_window.close_bt;
            this.m_closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         }
         if(m_window["title_tf"])
         {
            this.m_windowTitle = new ZwTextField(m_window["title_tf"],"Fantasy Felines");
         }
         if(m_window.whatisthis_mc)
         {
            this.m_whatisthisBtn = new GenericButton(m_window.whatisthis_mc,this.onWhatIsThisClick);
         }
         if(m_window.slotFrame_mc)
         {
            this.m_slotFrames = m_window.slotFrame_mc;
            if(this.m_slotFrames.feedSlot_mc)
            {
               this.m_feedSlot = this.m_slotFrames.feedSlot_mc;
            }
            if(this.m_slotFrames.crateSlot_mc)
            {
               this.m_crateSlot = this.m_slotFrames.crateSlot_mc;
            }
            if(Boolean(this.m_slotFrames.elder_tf) && Boolean(this.m_animal) && this.m_animal.isElderAnimal())
            {
               this.m_elderString = new ZwTextField(this.m_slotFrames.elder_tf,ZLocUtils.t("Dialogs","EvolutionElderString"));
            }
            else if(this.m_slotFrames.elder_tf)
            {
               this.m_slotFrames.elder_tf.visible = false;
            }
         }
         if(m_window.animalFrame_mc)
         {
            this.m_animalFrames = m_window.animalFrame_mc;
         }
      }
      
      private function setupItemSlots() : void
      {
         var crateIcon:FarmIcon = null;
         var feedIcon:FarmIcon = null;
         var crateItem:FarmItem = EvolutionManager.instance.getCrate();
         if(this.m_crateSlot)
         {
            if(this.m_crateSlot.icon_mc)
            {
               crateIcon = new FarmIcon(this.m_crateSlot.icon_mc,crateItem.iconUrl);
               crateIcon.setSmoothing(true);
               crateIcon.setIconSize(this.m_crateSlot.icon_mc.width,this.m_crateSlot.icon_mc.height);
            }
            if(this.m_crateSlot.buy_bt)
            {
               this.m_crateBuyBtn = new FarmAnimatedCashButton(this.m_crateSlot.buy_bt,ZLocUtils.t("Dialogs","BuyParts"),crateItem.cash.toString(),this.onBuyCrateClick);
            }
            if(this.m_crateSlot.itemTitle_tf)
            {
               this.m_crateSlot.itemTitle_tf = new ZwTextField(this.m_crateSlot.itemTitle_tf,crateItem.friendlyTitle,false);
            }
         }
         var feedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(EvolutionManager.instance.getFeedType(this.m_animal.getItemName()));
         if(Boolean(this.m_feedSlot) && Boolean(feedItem))
         {
            if(this.m_feedSlot.icon_mc)
            {
               feedIcon = new FarmIcon(this.m_feedSlot.icon_mc,feedItem.iconUrl);
               feedIcon.setSmoothing(true);
               feedIcon.fitIconInsideBounds(this.m_feedSlot.icon_mc.width,this.m_feedSlot.icon_mc.height);
            }
            if(this.m_feedSlot.itemTitle_tf)
            {
               this.m_feedSlot.itemTitle_tf = new ZwTextField(this.m_feedSlot.itemTitle_tf,feedItem.friendlyTitle,false);
            }
            if(this.m_feedSlot.itemAmount_tf)
            {
               this.m_feedSlot.itemAmount_tf = new ZwTextField(this.m_feedSlot.itemAmount_tf,this.generateFeedAmountText(),false);
            }
            if(this.m_feedSlot.feedAmount_tf)
            {
               this.m_feedSlot.feedAmount_tf = new ZwTextField(this.m_feedSlot.feedAmount_tf,"x" + EvolutionManager.instance.getfeedAmount(this.m_animal.feedType),false);
            }
            if(this.m_feedSlot.buy_bt)
            {
               this.m_feedBuyBtn = new FarmAnimatedCashButton(this.m_feedSlot.buy_bt,ZLocUtils.t("Dialogs","EvolutionBuyFeed"),feedItem.realCashCost.toString(),this.onBuyFeedClick);
            }
            if(this.m_feedSlot.complete_bt)
            {
               this.m_completeBtn = new FarmAnimatedCashButton(this.m_feedSlot.complete_bt,ZLocUtils.t("Dialogs","EvolutionCompleteMeow"),this.m_animal.calculateCompleteNowCost().toString(),this.onCompleteClick);
               if(this.m_animal.feedCompleted >= this.m_animal.feedRequired)
               {
                  this.m_completeBtn.toggleClickableButton(false);
               }
            }
            if(this.m_feedSlot.use_mat_bt)
            {
               this.m_feedUseBtn = new FarmAnimatedButton(this.m_feedSlot.use_mat_bt,this.onUseFeedClick);
               if(this.m_feedSlot["use_mat_bt"]["generic_tf"])
               {
                  (this.m_feedSlot["use_mat_bt"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","EvolutionFeed");
                  if(this.m_animal.feedCompleted >= this.m_animal.feedRequired)
                  {
                     (this.m_feedSlot["use_mat_bt"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","EvolutionGrow");
                  }
                  else if(EvolutionManager.instance.getfeedAmount(this.m_animal.feedType) <= 0)
                  {
                     this.m_feedUseBtn.toggleClickableButton(false);
                  }
               }
            }
            if(this.m_feedSlot.ask_bt)
            {
               this.m_feedAskBtn = new FarmAnimatedButton(this.m_feedSlot.ask_bt,this.onCraftFoodClick);
               if(this.m_feedSlot["ask_bt"]["generic_tf"])
               {
                  (this.m_feedSlot["ask_bt"]["generic_tf"] as TextField).text = ZLocUtils.t("Dialogs","EvolutionCraftFood");
               }
            }
         }
         if(this.m_animal.isElderAnimal())
         {
            this.m_feedSlot.use_mat_bt.visible = false;
            this.m_feedSlot.buy_bt.visible = false;
            this.m_feedSlot.complete_bt.visible = false;
            this.m_feedSlot.itemAmount_tf.visible = false;
            this.m_feedSlot.feedAmount_tf.visible = false;
            this.m_feedSlot.icon_mc.visible = false;
            this.m_feedSlot.ask_bt.visible = false;
            this.m_feedSlot.itemTitle_tf.visible = false;
            this.m_feedSlot.visible = false;
         }
      }
      
      private function updateItemSlots() : void
      {
         if(!this.m_animal.isElderAnimal())
         {
            if(this.m_feedSlot.itemAmount_tf)
            {
               (this.m_feedSlot.itemAmount_tf as ZwTextField).text = this.generateFeedAmountText();
            }
            if(this.m_feedSlot.feedAmount_tf)
            {
               (this.m_feedSlot.feedAmount_tf as ZwTextField).text = "x" + EvolutionManager.instance.getfeedAmount(this.m_animal.feedType);
            }
            if(EvolutionManager.instance.getfeedAmount(this.m_animal.feedType) <= 0)
            {
               this.m_feedUseBtn.toggleClickableButton(false);
            }
            else
            {
               this.m_feedUseBtn.toggleClickableButton(true);
            }
         }
      }
      
      private function setupAnimalSlots() : void
      {
         var animalSlot:MovieClip = null;
         var animalItem:FarmItem = null;
         var animalIcon:FarmItemIcon = null;
         for(var i:int = 1; i <= NUM_ANIMAL_SLOTS; i++)
         {
            animalSlot = this.m_animalFrames.getChildByName("animal" + i + "_mc") as MovieClip;
            if(animalSlot)
            {
               animalItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_slotToAnimalMapping[i - 1]);
               animalIcon = new FarmItemIcon(new ZwFrame(animalSlot),animalSlot,animalItem,true);
               if(!this.isAnimalInArray(this.m_slotToAnimalMapping[i - 1],this.m_animal.history))
               {
                  animalIcon.element.alpha = ALPHA_VALUE;
               }
            }
         }
      }
      
      private function isAnimalInArray(animal:String, array:Array) : Boolean
      {
         var animalName:String = null;
         var result:Boolean = false;
         for each(animalName in array)
         {
            if(animal == animalName)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      private function generateFeedAmountText() : String
      {
         return this.m_animal.feedCompleted + " of " + this.m_animal.feedRequired;
      }
      
      override public function close() : void
      {
         this.m_isShowing = false;
         super.close();
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         this.close();
         this.m_closeBtn.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
      }
      
      private function onWhatIsThisClick(event:MouseEvent) : void
      {
         EvolutionManager.instance.showHowDoesThisWork();
      }
      
      private function onCraftFoodClick(event:MouseEvent) : void
      {
         EvolutionManager.instance.openCraftShop();
         this.close();
      }
      
      private function onBuyFeedClick(event:MouseEvent) : void
      {
         EvolutionManager.instance.buyFeed(this.m_animal.feedType,1);
         this.refreshWindow();
      }
      
      private function onCompleteClick(event:MouseEvent) : void
      {
         EvolutionManager.instance.beginCompleteNowFlow(this.m_animal);
         this.close();
      }
      
      private function onBuyCrateClick(event:MouseEvent) : void
      {
         this.close();
         EvolutionManager.instance.buyCrate();
      }
      
      private function onUseFeedClick(event:MouseEvent) : void
      {
         EvolutionManager.instance.feed(this.m_animal,this.m_animal.feedType);
         this.refreshWindow();
      }
      
      public function refreshWindow() : void
      {
         this.m_feedBuyBtn.enabled = true;
         this.updateItemSlots();
      }
      
      public function isShowing() : Boolean
      {
         return this.m_isShowing;
      }
   }
}

