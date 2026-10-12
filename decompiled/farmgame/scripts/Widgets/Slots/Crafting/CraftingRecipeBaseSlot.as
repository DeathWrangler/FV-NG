package Widgets.Slots.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Player;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.FarmGameSettingsManager;
   import Managers.HangingGardensManager;
   import Managers.RetentionMasterManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CraftingRecipeBaseSlot extends ZwSlotFrame
   {
      
      public static const MAX_RECIPE_INGREDIENT_SLOTS:int = 3;
      
      public static const RECIPE_NO_END_TIME:Number = -1;
      
      protected var m_background:ZwWidget;
      
      protected var m_backgroundLE:ZwWidget;
      
      protected var m_makeIt:FarmAnimatedTextButton;
      
      protected var m_recipeId:String;
      
      protected var m_recipeIcon:FarmIcon;
      
      protected var m_recipeName:ZwTextField;
      
      protected var m_recipeItem:RecipeItem = null;
      
      protected var m_locked:ZwWidget;
      
      protected var m_lockedText:ZwTextField;
      
      protected var m_lockedDescription:ZwTextField;
      
      protected var m_recipeReward:ZwTextField = null;
      
      protected var m_makeItToolTip:FarmTextTooltip = null;
      
      protected var m_makeItEnabled:int = 0;
      
      protected var m_callBackObject:Object;
      
      public function CraftingRecipeBaseSlot(element:DisplayObject, callBackObject:Object)
      {
         this.m_callBackObject = callBackObject;
         super(element);
         if(this.element.hasOwnProperty("celBackgroundDefault_mc"))
         {
            this.m_background = addWidget(new ZwWidget(this.element.celBackgroundDefault_mc)) as ZwWidget;
         }
         this.m_recipeIcon = addWidget(new FarmIcon(this.element.icon_mc,Player.NO_PROFILE_PIC_URL)) as FarmIcon;
         this.m_recipeName = addWidget(new ZwTextField(this.element.recipeName_tf,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_placeholder_name"))) as ZwTextField;
         if(this.element.hasOwnProperty("lockedRecipe_mc"))
         {
            this.m_locked = addWidget(new ZwWidget(this.element.lockedRecipe_mc),false) as ZwWidget;
            this.m_lockedText = addWidget(new ZwTextField(this.element.lockedRecipe_mc.locked_tf,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_placeholder_locked")),false) as ZwTextField;
            this.m_lockedDescription = addWidget(new ZwTextField(this.element.lockedRecipe_mc.description_tf,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_placeholder_reason")),false) as ZwTextField;
         }
         if(this.element.hasOwnProperty("make_bt"))
         {
            this.m_makeIt = addWidget(new FarmAnimatedTextButton(this.element.make_bt,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_make_btn"),this.pressMake)) as FarmAnimatedTextButton;
            this.m_makeItToolTip = new FarmTextTooltip("");
            this.m_makeIt.attachTooltip(this.m_makeItToolTip);
         }
         if(this.element.hasOwnProperty("recipeReward_tf"))
         {
            this.m_recipeReward = addWidget(new ZwTextField(this.element.recipeReward_tf)) as ZwTextField;
         }
      }
      
      public static function shouldShowExpirationWarning() : Boolean
      {
         var result:Boolean = false;
         var craftingOverhaulVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFTING_OVERHAUL);
         if(!(RetentionMasterManager.inMasterExperiment() && (craftingOverhaulVariant == 2 || craftingOverhaulVariant == 4)))
         {
            result = true;
         }
         return result;
      }
      
      public static function getExpirationTime(prerequisites:Array) : Number
      {
         var prereqType:String = null;
         var prerequisite:Object = null;
         var result:Number = RECIPE_NO_END_TIME;
         for each(prerequisite in prerequisites)
         {
            prereqType = prerequisite[PrerequisiteConstants.KEY_TYPE];
            if(prereqType == PrerequisiteConstants.PREREQUISITE_END_TIME)
            {
               result = FarmGameUtil.synchronizedDateTimeToNumber(prerequisite[PrerequisiteConstants.KEY_VALUE]);
               break;
            }
            if(prereqType == PrerequisiteConstants.PREREQUISITE_OR_GROUP || prereqType == PrerequisiteConstants.PREREQUISITE_AND_GROUP)
            {
               result = getExpirationTime(prerequisite[FarmGameSettingsManager.XML_CHILDREN_FIELD]);
               if(result != RECIPE_NO_END_TIME)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      public function pressMake(event:MouseEvent) : void
      {
         if(this.m_makeItEnabled == CraftingConstants.CAN_MAKE_RECIPE)
         {
            this.m_callBackObject.makeRecipe(this.m_recipeId);
         }
      }
      
      protected function updateMakeButton(canMakeRecipeStatus:int, recipeItem:RecipeItem = null) : void
      {
         this.m_makeItEnabled = canMakeRecipeStatus;
         this.m_makeIt.applyGrayOut = canMakeRecipeStatus != CraftingConstants.CAN_MAKE_RECIPE;
         if(canMakeRecipeStatus == CraftingConstants.CAN_MAKE_RECIPE)
         {
            this.m_makeItToolTip.setText("");
         }
         else if(canMakeRecipeStatus == CraftingConstants.OVEN_SLOTS_FULL)
         {
            if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
            {
               this.m_makeItToolTip.setText(ZLocUtils.t("Dialogs","CraftshopRecipeSlot_slotFull"));
            }
            else
            {
               this.m_makeItToolTip.setText(ZLocUtils.t("Dialogs","CraftshopRecipeSlot_RecipeBeingMade"));
            }
         }
         else if(canMakeRecipeStatus == CraftingConstants.MAX_BUSHEL_CAPACITY)
         {
            this.m_makeItToolTip.setText(ZLocUtils.t("Dialogs","CraftshopRecipeSlot_BushelLimitBackup"));
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
      }
   }
}

