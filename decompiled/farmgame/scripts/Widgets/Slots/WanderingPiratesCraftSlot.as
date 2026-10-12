package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Managers.WanderingPirateManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.WanderingPirateWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class WanderingPiratesCraftSlot extends ZwSlotFrame
   {
      
      protected var m_owner:DisplayObject;
      
      private var m_data:Object;
      
      private var m_countTextField:ZwTextField;
      
      private var m_makeButton:FarmAnimatedTextButton;
      
      private var m_recipeIcon:FarmIcon;
      
      private var m_recipe:RecipeItem;
      
      private var m_featureName:String;
      
      public function WanderingPiratesCraftSlot(element:DisplayObject, owner:DisplayObject)
      {
         super(element);
         this.m_owner = owner;
         this.m_featureName = WanderingPirateManager.FEATURE_NAME;
         if(m_element.hasOwnProperty("craftType_txt"))
         {
            addWidget(this.m_countTextField = new ZwTextField(m_element.craftType_txt,""));
         }
         if(m_element.hasOwnProperty("make_bt"))
         {
            addWidget(this.m_makeButton = new FarmAnimatedTextButton(m_element.make_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_make"),this.onMakeButtonClicked));
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_recipeIcon = new FarmIcon(m_element.icon_mc));
         }
      }
      
      public function onMakeButtonClicked(event:Event = null) : void
      {
         var craftShopName:String = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
         var partiallyBuiltShops:Array = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopBuildable());
         var completedShops:Array = Global.world.getObjectsByNames(Global.craftConfigSettings.getCraftingWorkshopFinished());
         if(!(partiallyBuiltShops.length > 0 || completedShops.length > 0))
         {
            (this.m_owner as WanderingPirateWindow).close();
         }
         CraftingManager.getInstance().openCraftingUiForRecipe(this.m_data["craftingRecipe"],craftShopName);
         (this.m_owner as WanderingPirateWindow).close();
      }
      
      override public function populate(data:Object) : void
      {
         var rewardRecipeItem:FarmItem = null;
         var infoTooltip:FarmTextTooltip = null;
         super.populate(data);
         this.m_data = data;
         this.m_recipe = Global.craftConfigSettings.getRecipeById(this.m_data["craftingRecipe"]);
         if(this.m_recipe)
         {
            rewardRecipeItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_recipe.rewardItemCode);
         }
         if(Boolean(rewardRecipeItem) && Boolean(this.m_countTextField))
         {
            this.m_countTextField.text = rewardRecipeItem.friendlyTitle;
            this.m_countTextField.visible = true;
         }
         if(Boolean(this.m_recipe) && Boolean(rewardRecipeItem) && Boolean(this.m_makeButton))
         {
            infoTooltip = new FarmTextTooltip(ZLocUtils.t("Dialogs",this.m_featureName + "_craftTooltip",{
               "recipe":this.m_recipe.friendlyTitle,
               "quantity":rewardRecipeItem.count.toString()
            }));
            this.m_makeButton.attachTooltip(infoTooltip);
            this.m_makeButton.visible = true;
         }
         if(Boolean(this.m_recipe) && Boolean(this.m_recipeIcon))
         {
            this.m_recipeIcon.loadIcon(this.m_recipe.image);
            this.m_recipeIcon.setIconSize(100,100);
            this.m_recipeIcon.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_countTextField = null;
         this.m_makeButton = null;
         super.release();
      }
   }
}

