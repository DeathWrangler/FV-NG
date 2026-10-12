package Widgets.Slots.Crafting
{
   import Classes.Combine;
   import Classes.Constants.Experiments;
   import Classes.RotatableCombine;
   import Classes.RotatableSeeder;
   import Classes.Seeder;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Crafting.CraftingMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class CraftingMainRecipeDetailSlot extends ZwSlotFrame
   {
      
      private static const EXPERIMENT_FLASH_CRAFTING_BUY_BUSHELS:String = "fv_crafting_buy_bushels_2";
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_ingredient:Object;
      
      private var m_craftingWindow:CraftingMainWindow;
      
      private var m_buyBtn:FarmAnimatedCashButton;
      
      private var m_plantBtn:FarmAnimatedTextButton;
      
      private var m_dooberMc:MovieClip;
      
      private var m_recipeItem:RecipeItem;
      
      private var m_crop:String;
      
      private var m_icon:FarmIcon;
      
      public function CraftingMainRecipeDetailSlot(element:DisplayObject, craftingWindow:CraftingMainWindow, recipeItem:RecipeItem)
      {
         super(element);
         this.m_craftingWindow = craftingWindow;
         this.m_recipeItem = recipeItem;
         addWidget(new ZwTextField(m_element.generic_tf));
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         addWidget(new ZwWidget(m_element.counterCircle_mc));
         addWidget(new ZwTextField(m_element.counter_tf));
         (getWidget(m_element.icon_mc) as FarmIcon).setIconSize(50,50);
         (getWidget(m_element.icon_mc) as FarmIcon).x = (getWidget(m_element.icon_mc) as FarmIcon).x + 5;
         this.m_toolTip = new FarmTextTooltip();
         this.m_icon.attachTooltip(this.m_toolTip);
         if(Global.experimentManager.getExperimentVariant(EXPERIMENT_FLASH_CRAFTING_BUY_BUSHELS) > 2 && m_element.buy_bt != null)
         {
            this.m_buyBtn = new FarmAnimatedCashButton(this.element.buy_bt,ZLocUtils.t("Dialogs","Buy"),"1",this.pressBuyBushel);
            addWidget(this.m_buyBtn);
         }
         if(m_element.plant_mc != null)
         {
            this.m_plantBtn = new FarmAnimatedTextButton(this.element.plant_mc,"Plant",this.onPlantButtonClick) as FarmAnimatedTextButton;
            addWidget(this.m_plantBtn);
         }
         if(m_element.hasOwnProperty("dooberAdd_mc"))
         {
            this.m_dooberMc = m_element.dooberAdd_mc as MovieClip;
         }
      }
      
      public function update(ingredient:Object, craftType:String) : Boolean
      {
         var friend:Dictionary = null;
         this.m_ingredient = ingredient;
         var itemCode:String = ingredient.itemCode;
         var ingredientItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var quantityRequired:int = int(ingredient.quantityRequired);
         var numIngredients:int = CraftingManager.getInstance().getInventoryCountHelper(itemCode,quantityRequired,craftType);
         var complete:Boolean = numIngredients >= quantityRequired;
         var amountZwTextField:ZwTextField = getWidget(m_element.generic_tf) as ZwTextField;
         amountZwTextField.text = numIngredients.toString() + "/" + quantityRequired.toString();
         amountZwTextField.visible = true;
         var iconFarmIcon:FarmIcon = getWidget(m_element.icon_mc) as FarmIcon;
         if(ingredientItem != null)
         {
            iconFarmIcon.loadIcon(ingredientItem.icon);
            iconFarmIcon.visible = true;
            this.m_toolTip.setText(ingredientItem.friendlyTitle);
         }
         var friendsWithBushel:Array = MarketViewManager.getInstance().getFriendsWithBushel(itemCode);
         var numFriends:int = 0;
         for each(friend in friendsWithBushel)
         {
            if(friend["timeToBags"] == 0)
            {
               numFriends++;
            }
         }
         if(numFriends == 0)
         {
            (getWidget(m_element.counterCircle_mc) as ZwWidget).visible = false;
            (getWidget(m_element.counter_tf) as ZwTextField).visible = false;
         }
         else
         {
            (getWidget(m_element.counterCircle_mc) as ZwWidget).visible = true;
            (getWidget(m_element.counter_tf) as ZwTextField).visible = true;
            (getWidget(m_element.counter_tf) as ZwTextField).text = numFriends.toString();
         }
         if(this.m_buyBtn != null)
         {
            this.m_buyBtn.visible = true;
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_DISABLE_BUY_BUTTON) > 0 && numIngredients >= quantityRequired)
            {
               this.m_buyBtn.toggleClickableButton(false,ZLocUtils.t("Dialogs","crafting_buydisabled_message"));
            }
            else
            {
               this.m_buyBtn.toggleClickableButton(true);
            }
         }
         this.m_crop = ingredientItem.crop;
         if(this.m_crop != null && this.m_crop != "" && Boolean(this.m_plantBtn))
         {
            this.m_plantBtn.visible = true;
         }
         return complete;
      }
      
      public function updateRecipeItem(recipeItem:RecipeItem) : void
      {
         this.m_recipeItem = recipeItem;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_toolTip = null;
      }
      
      public function pressBuyBushel(e:Event) : void
      {
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_DISABLE_BUY_BUTTON) > 0 && Boolean(this.m_dooberMc))
         {
            this.m_dooberMc.visible = true;
            this.m_dooberMc.gotoAndPlay(0);
         }
         var recipeId:String = this.m_recipeItem ? this.m_recipeItem.id : "";
         this.m_craftingWindow.buyBushel(this.m_ingredient.itemCode,recipeId);
      }
      
      public function onPlantButtonClick(event:MouseEvent) : void
      {
         var itemNames:Array = new Array();
         var farmItemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_crop);
         itemNames.push(farmItemName);
         this.m_craftingWindow.close();
         if(itemNames.length > 0)
         {
            if(Boolean(Global.world.getEquipment(Combine,null) as Combine) || Boolean(Global.world.getEquipment(RotatableCombine,null) as RotatableCombine))
            {
               UI.marketLaunchReference = UI.MARKET_LAUNCH_REFERENCE_COMBINE;
            }
            else if(Boolean(Global.world.getEquipment(Seeder,null) as Seeder) || Boolean(Global.world.getEquipment(RotatableSeeder,null) as RotatableSeeder))
            {
               UI.marketLaunchReference = UI.MARKET_LAUNCH_REFERENCE_SEEDER;
            }
            else
            {
               UI.marketLaunchReference = null;
            }
            UI.displayMiniMarketDialog(itemNames);
         }
         FarmStatsManager.count("craftingMain","plantButton","click");
      }
   }
}

