package Widgets.Frames.Crafting
{
   import Classes.Combine;
   import Classes.Constants.Experiments;
   import Classes.RotatableCombine;
   import Classes.RotatableSeeder;
   import Classes.Seeder;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class CraftshopRecipeIngredientFrame extends CraftingRecipeIngredientBaseFrame
   {
      
      private var m_counterCircle:ZwWidget;
      
      private var m_counter:ZwTextField;
      
      private var m_check:ZwWidget;
      
      private var m_buyBtn:FarmAnimatedCashButton;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_plantButton:FarmAnimatedTextButton;
      
      private var m_callBackObject:Object;
      
      private var m_recipe:RecipeItem;
      
      private var m_ingredientConfig:Object;
      
      private var m_featureName:String;
      
      private var m_crop:String;
      
      public function CraftshopRecipeIngredientFrame(element:DisplayObject, callbackObj:Object = null, featureName:String = "")
      {
         super(element);
         this.m_counterCircle = addWidget(new ZwWidget(m_element.counterCircle_mc),false) as ZwWidget;
         this.m_counter = addWidget(new ZwTextField(m_element.counter_tf,""),false) as ZwTextField;
         this.m_check = addWidget(new ZwWidget(m_element.checkMark_mc),false) as ZwWidget;
         this.m_featureName = featureName;
         if(m_element.buy_mc != null)
         {
            this.m_buyBtn = addWidget(new FarmAnimatedCashButton(m_element.buy_mc,"Buy","1",this.pressBuyBushel)) as FarmAnimatedCashButton;
         }
         if(m_element.getThis_mc)
         {
            this.m_askButton = addWidget(new FarmAnimatedTextButton(m_element.getThis_mc,"Ask",this.onAskButtonClick)) as FarmAnimatedTextButton;
         }
         if(m_element.plant_mc)
         {
            this.m_plantButton = addWidget(new FarmAnimatedTextButton(m_element.plant_mc,"Plant",this.onPlantButtonClick)) as FarmAnimatedTextButton;
         }
         this.m_callBackObject = callbackObj;
      }
      
      override public function release() : void
      {
         this.m_askButton = null;
         this.m_buyBtn = null;
         this.m_callBackObject = null;
         this.m_plantButton = null;
         this.m_check = null;
         this.m_counter = null;
         this.m_counterCircle = null;
         this.m_featureName = null;
         m_getBushel = null;
         m_icon = null;
         m_info = null;
         this.m_ingredientConfig = null;
         this.m_recipe = null;
         m_toolTip = null;
         super.release();
      }
      
      public function update(recipeItem:RecipeItem, ingredientIndex:int) : void
      {
         var itemCode:String = null;
         var ingredientItem:FarmItem = null;
         var friendsWithBushel:Array = null;
         var friend:Dictionary = null;
         var numFriends:int = 0;
         var bushelName:String = null;
         var replacements:Object = null;
         var isIngredientGetByFeed:Boolean = false;
         var canPublishGetByFeedIngredient:Boolean = false;
         var hoverOvertext:String = null;
         var feedLimitSeconds:Number = NaN;
         var timeLeft:Number = NaN;
         var cropToHarvest:FarmItem = null;
         var nRequired:int = 0;
         var nHave:int = 0;
         this.m_widgetManager.hideAllWidgets();
         this.visible = true;
         this.m_recipe = recipeItem;
         if(Boolean(this.m_recipe) && Boolean(this.m_recipe.ingredients) && this.m_recipe.ingredients.hasOwnProperty(ingredientIndex.toString()))
         {
            this.m_ingredientConfig = this.m_recipe.ingredients[ingredientIndex];
            itemCode = this.m_ingredientConfig[RecipeItem.ITEM_CODE];
            if(itemCode)
            {
               ingredientItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(ingredientItem)
               {
                  if(ingredientItem.icon)
                  {
                     m_icon.loadIcon(ingredientItem.icon);
                     m_icon.setIconSize(50,50);
                     if(CraftingManager.shouldUseNewCraftshopInFeature(this.m_featureName))
                     {
                        m_icon.setIconSize(100,100);
                     }
                     m_icon.visible = true;
                  }
                  if(this.m_ingredientConfig[RecipeItem.QUANTITY_REQUIRED])
                  {
                     nRequired = int(this.m_ingredientConfig[RecipeItem.QUANTITY_REQUIRED]);
                     nHave = CraftingManager.getInstance().getInventoryCountHelper(itemCode,nRequired,this.m_recipe.craft);
                     m_info.text = nHave.toString() + "/" + nRequired;
                     m_info.visible = true;
                     if(this.m_check != null)
                     {
                        this.m_check.visible = nHave >= nRequired;
                     }
                  }
                  numFriends = 0;
                  friendsWithBushel = MarketViewManager.getInstance().getFriendsWithBushel(itemCode);
                  for each(friend in friendsWithBushel)
                  {
                     if(friend["timeToBags"] == 0)
                     {
                        numFriends++;
                     }
                  }
                  if(numFriends > 0)
                  {
                     this.m_counter.text = numFriends.toString();
                     this.m_counter.visible = true;
                     this.m_counterCircle.visible = true;
                  }
                  else
                  {
                     this.m_counter.visible = false;
                     this.m_counterCircle.visible = false;
                  }
                  bushelName = ingredientItem.friendlyTitle;
                  replacements = {};
                  replacements["bushelName"] = bushelName;
                  isIngredientGetByFeed = CraftingManager.getInstance().isIngredientGetByFeed(this.m_ingredientConfig);
                  canPublishGetByFeedIngredient = isIngredientGetByFeed && CraftingManager.getInstance().canPublishGetByFeedIngredient(this.m_recipe,this.m_ingredientConfig);
                  hoverOvertext = bushelName;
                  this.m_crop = ingredientItem.crop;
                  if(this.m_crop != null && this.m_crop != "" && Boolean(this.m_plantButton))
                  {
                     this.m_plantButton.visible = true;
                  }
                  if(isIngredientGetByFeed)
                  {
                     if(canPublishGetByFeedIngredient)
                     {
                        feedLimitSeconds = Global.craftConfigSettings.getRecipeIngredientRequestFeedLimitSeconds();
                        replacements["time"] = FarmGameUtil.toFriendlyTime(feedLimitSeconds,true);
                        hoverOvertext = ZLocUtils.t("Dialogs","CraftshopRecipeIngredientFrameGetByFeed_tooltip",replacements);
                     }
                     else
                     {
                        timeLeft = CraftingManager.getInstance().getTimeUntilCanPublishGetByFeedIngredient(this.m_recipe,this.m_ingredientConfig);
                        replacements["time"] = FarmGameUtil.toFriendlyTime(timeLeft);
                        hoverOvertext = ZLocUtils.t("Dialogs","CraftshopRecipeIngredientFrameGetByFeedTimeRemaining_tooltip",replacements);
                     }
                  }
                  else
                  {
                     m_toolTip.setTextFunction(null);
                     if(this.m_crop != "")
                     {
                        cropToHarvest = Global.farmGameSettingsManager.getFarmItemByCode(this.m_crop);
                        if(cropToHarvest != null)
                        {
                           replacements["cropName"] = ZLocUtils.tk_pk_asTitlePlural(cropToHarvest.friendlyName);
                           hoverOvertext = ZLocUtils.t("Dialogs","CraftshopRecipeIngredientFrame_tooltip",replacements);
                        }
                     }
                     else
                     {
                        hoverOvertext = ZLocUtils.t("Dialogs","CraftshopRecipeIngrdientFrameNoCrop_tooltip",replacements);
                     }
                  }
                  m_toolTip.setText(hoverOvertext);
                  if(this.m_buyBtn != null && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_BUY_BUSHELS) > 0)
                  {
                     this.m_buyBtn.setAmountText(String(CraftingManager.getInstance().getBushelPrice(ingredientItem)));
                     this.m_buyBtn.visible = true;
                     if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_DISABLE_BUY_BUTTON) > 0 && nHave >= nRequired)
                     {
                        this.m_buyBtn.toggleClickableButton(false,ZLocUtils.t("Dialogs","crafting_buydisabled_message"));
                     }
                     else
                     {
                        this.m_buyBtn.toggleClickableButton(true);
                     }
                  }
                  if(Boolean(this.m_askButton) && isIngredientGetByFeed)
                  {
                     this.m_askButton.enabled = canPublishGetByFeedIngredient;
                     this.m_askButton.visible = true;
                  }
               }
            }
         }
      }
      
      public function pressBuyBushel(event:MouseEvent) : void
      {
         if(this.m_callBackObject != null)
         {
            this.m_callBackObject.buyBushel(this.m_ingredientConfig[RecipeItem.ITEM_CODE],this.m_recipe.id);
         }
      }
      
      public function onAskButtonClick(event:MouseEvent) : void
      {
         if(this.m_callBackObject != null)
         {
            this.m_callBackObject.askForBushel(this.m_recipe,this.m_ingredientConfig);
            this.m_askButton.enabled = false;
         }
      }
      
      public function onPlantButtonClick(event:MouseEvent) : void
      {
         var itemNames:Array = new Array();
         var farmItemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(this.m_crop);
         itemNames.push(farmItemName);
         this.m_callBackObject.closeMainWindow();
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
            UI.displayMiniMarketDialog(itemNames,"","",null,false);
         }
         FarmStatsManager.count("craftshop","plantButton","click");
      }
   }
}

