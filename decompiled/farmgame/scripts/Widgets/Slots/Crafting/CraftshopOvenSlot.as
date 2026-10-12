package Widgets.Slots.Crafting
{
   import Classes.Constants.WorldsConstants;
   import Classes.HangingGardensCraftingShopBuilding;
   import Classes.Player;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.HangingGardensCraftingShopRecipeQueueManager;
   import Managers.HangingGardensManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftshopOvenFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Crafting.CraftshopWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class CraftshopOvenSlot extends ZwSlotFrame
   {
      
      protected var m_window:CraftshopWindow = null;
      
      protected var m_recipeId:String = null;
      
      protected var m_ovenSlot:int = -1;
      
      protected var m_recipeItem:RecipeItem = null;
      
      private var m_statusText:ZwTextField = null;
      
      private var m_statusText2:ZwTextField = null;
      
      private var m_readyTimeText:ZwTextField = null;
      
      private var m_recipeIcon:FarmIcon = null;
      
      private var m_finishNow:FarmAnimatedTextButton = null;
      
      private var m_collect:FarmAnimatedTextButton = null;
      
      private var m_expand:FarmAnimatedTextButton = null;
      
      private var m_bgDone:FarmIcon = null;
      
      private var m_bgInProgress:FarmIcon = null;
      
      private var m_bgOpen:FarmIcon = null;
      
      private var m_bgUnlocked:FarmIcon = null;
      
      private var m_bgLocked:FarmIcon = null;
      
      private var m_rolloverTooltip:FarmTextTooltip = null;
      
      private var m_featureName:String;
      
      public function CraftshopOvenSlot(element:DisplayObject, window:CraftshopWindow, featureName:String = "")
      {
         this.m_window = window;
         this.m_featureName = featureName;
         super(element);
         this.m_statusText = addWidget(new ZwTextField(this.element.status_tf)) as ZwTextField;
         this.m_statusText2 = addWidget(new ZwTextField(this.element.status2_tf)) as ZwTextField;
         if(m_element.readyTime_tf)
         {
            this.m_readyTimeText = addWidget(new ZwTextField(this.element.readyTime_tf)) as ZwTextField;
         }
         this.m_recipeIcon = addWidget(new FarmIcon(this.element.icon_mc,Player.NO_PROFILE_PIC_URL)) as FarmIcon;
         this.m_rolloverTooltip = new FarmTextTooltip();
         this.attachTooltip(this.m_rolloverTooltip);
         this.m_finishNow = addWidget(new FarmAnimatedTextButton(m_element.finishNow_bt,ZLocUtils.t("Crafting","CraftingMain_Finish"),this.onFinishNow)) as FarmAnimatedTextButton;
         this.m_collect = addWidget(new FarmAnimatedTextButton(m_element.collect_mc,ZLocUtils.t("Crafting","CraftingMain_GetIt"),this.onCollect)) as FarmAnimatedTextButton;
         this.m_expand = addWidget(new FarmAnimatedTextButton(m_element.expand_mc,ZLocUtils.t("Crafting","CraftingMain_OvenSlot_Expand"),this.onExpand)) as FarmAnimatedTextButton;
         this.m_bgDone = addWidget(new FarmIcon(m_element.ready_mc)) as FarmIcon;
         this.m_bgInProgress = addWidget(new FarmIcon(m_element.on_mc)) as FarmIcon;
         this.m_bgOpen = addWidget(new FarmIcon(m_element.open_mc)) as FarmIcon;
         this.m_bgUnlocked = addWidget(new FarmIcon(m_element.unlocked_mc)) as FarmIcon;
         this.m_bgLocked = addWidget(new FarmIcon(m_element.locked_mc)) as FarmIcon;
         if(CraftingManager.shouldUseNewCraftshopInFeature(this.m_featureName))
         {
            this.m_window.addEventListener(CraftshopWindow.CRAFTSHOP_TUTORIAL_EVENT,this.disableExpandButton);
            this.m_window.addEventListener(CraftshopWindow.CRAFTSHOP_TUTORIAL_EVENT_END,this.enableExpandButton);
         }
      }
      
      public function disableExpandButton(event:Event) : void
      {
         this.m_window.removeEventListener(CraftshopWindow.CRAFTSHOP_TUTORIAL_EVENT,this.disableExpandButton);
         this.m_expand.enabled = false;
      }
      
      public function enableExpandButton(event:Event) : void
      {
         this.m_window.removeEventListener(CraftshopWindow.CRAFTSHOP_TUTORIAL_EVENT_END,this.enableExpandButton);
         this.m_expand.enabled = true;
      }
      
      private function onFinishNow(event:MouseEvent) : void
      {
         this.m_window.showExpandFrame(false);
         this.m_window.finishRecipeRushed(this.m_recipeId,this.m_ovenSlot);
      }
      
      private function onCollect(event:MouseEvent) : void
      {
         this.m_window.showExpandFrame(false);
         this.m_window.finishRecipe(this.m_recipeId,this.m_ovenSlot);
      }
      
      private function onExpand(event:MouseEvent) : void
      {
         this.m_window.showExpandFrame(true);
      }
      
      override public function populate(data:Object) : void
      {
         var remainingRecipes:int = 0;
         super.populate(data);
         this.m_recipeId = "";
         this.m_recipeItem = null;
         if(data.hasOwnProperty("recipeId"))
         {
            this.m_recipeId = data.recipeId;
            this.m_recipeItem = Global.craftConfigSettings.getRecipeById(data.recipeId);
         }
         if(data.hasOwnProperty("ovenSlot"))
         {
            this.m_ovenSlot = data.ovenSlot;
         }
         if(data.hasOwnProperty("finishTime"))
         {
            this.m_rolloverTooltip.setText(data.finishTime);
         }
         this.m_statusText.unregisterEventListener(MouseEvent.CLICK,this.onExpand);
         this.m_statusText2.unregisterEventListener(MouseEvent.CLICK,this.onExpand);
         if(data.hasOwnProperty("recipeState"))
         {
            switch(data.recipeState)
            {
               case CraftshopOvenFrame.ICON_STATE_RECIPE_COMPLETE:
                  this.m_bgDone.visible = true;
                  this.m_collect.visible = true;
                  this.showRecipeIcon();
                  break;
               case CraftshopOvenFrame.ICON_STATE_IN_PROGRESS:
                  this.m_bgInProgress.visible = true;
                  this.m_finishNow.visible = true;
                  if(this.m_readyTimeText)
                  {
                     this.m_readyTimeText.text = ZLocUtils.t("Crafting","CraftingMain_ReadyTime",{"time":data.finishTime});
                     this.m_readyTimeText.visible = true;
                  }
                  this.showRecipeIcon();
                  break;
               case CraftshopOvenFrame.ICON_STATE_OPEN:
                  this.m_bgOpen.visible = true;
                  this.m_statusText.text = ZLocUtils.t("Crafting","CraftingMain_OvenSlot_Empty");
                  this.m_statusText.visible = true;
                  this.m_rolloverTooltip.setText(ZLocUtils.t("Crafting","CraftingMain_OvenSlotTip_IsEmpty"));
                  break;
               case CraftshopOvenFrame.ICON_STATE_UNLOCKED:
                  this.m_expand.visible = true;
                  this.m_expand.enabled = !this.m_window.isExpandFrameVisible();
                  this.m_bgUnlocked.visible = true;
                  this.m_statusText.text = "";
                  this.m_statusText.visible = true;
                  this.m_statusText.registerEventListener(MouseEvent.CLICK,this.onExpand);
                  if(HangingGardensManager.isInHangingGardensExperiment() && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_GARDEN && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
                  {
                     remainingRecipes = this.getRemainingRecipesToUnlockNextSlot();
                     this.m_rolloverTooltip.setText(ZLocUtils.t("Crafting","CraftingMain_OvenSlotTip_IsLocked_Recipes",{"numRecipes":remainingRecipes}));
                  }
                  else
                  {
                     this.m_rolloverTooltip.setText(ZLocUtils.t("Crafting","CraftingMain_OvenSlotTip_IsExpand"));
                  }
                  break;
               case CraftshopOvenFrame.ICON_STATE_LOCKED:
               case "":
               default:
                  this.m_bgLocked.visible = true;
                  this.m_statusText.text = "";
                  this.m_statusText.visible = true;
                  this.m_statusText2.text = ZLocUtils.t("Crafting","CraftingMain_OvenSlot_Locked");
                  this.m_statusText2.visible = true;
                  this.m_statusText.registerEventListener(MouseEvent.CLICK,this.onExpand);
                  this.m_statusText2.registerEventListener(MouseEvent.CLICK,this.onExpand);
                  this.m_rolloverTooltip.setText(ZLocUtils.t("Crafting","CraftingMain_OvenSlotTip_IsLocked"));
            }
         }
      }
      
      private function showRecipeIcon() : void
      {
         if(this.m_recipeItem)
         {
            if(this.m_recipeItem.image)
            {
               this.m_recipeIcon.loadIcon(this.m_recipeItem.image);
               this.m_recipeIcon.setSmoothing(true);
               this.m_recipeIcon.setIconSize(50,50);
               this.m_recipeIcon.visible = true;
            }
         }
      }
      
      public function getRemainingRecipesToUnlockNextSlot() : int
      {
         var upgradeLevel:String = null;
         var unlockConst:String = null;
         var unlockRecipesNeeded:int = 0;
         var totalNumRecipesCompleted:int = 0;
         var result:int = 0;
         var buildings:Array = Global.world.getObjectsByClass(HangingGardensCraftingShopBuilding);
         var hangingGardensCraftShopBuilding:HangingGardensCraftingShopBuilding = buildings[0] as HangingGardensCraftingShopBuilding;
         if(hangingGardensCraftShopBuilding.hasNextExpansion())
         {
            upgradeLevel = hangingGardensCraftShopBuilding.getNextExpansionLevel().toString();
            unlockConst = HangingGardensCraftingShopRecipeQueueManager.UNLOCK_PREFIX + upgradeLevel;
            unlockRecipesNeeded = int(HangingGardensCraftingShopRecipeQueueManager[unlockConst]);
            totalNumRecipesCompleted = Global.player.craftingState.getNumOfRecipesToCompleteByType(CraftingConstants.HANGING_GARDENS_CRAFTINGSHOP_SKILL);
            result = unlockRecipesNeeded - totalNumRecipesCompleted;
         }
         return result;
      }
   }
}

