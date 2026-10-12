package Widgets.Windows.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.GenericButton;
   import Engine.Managers.LoadingManager;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FeatureOptionsManager;
   import Managers.LabBuildingManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.GenericNumberSelectionWindow;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   
   public class PurchaseBushelBundles extends GenericNumberSelectionWindow
   {
      
      private const ASSET_DIALOG_v2:String = "assets/dialogs/FV_Craft_BuyIngredients_v2.swf";
      
      private var m_bundleCost:int = 3;
      
      protected var m_amountTextField:ZwTextField;
      
      protected var m_recipe:RecipeItem;
      
      protected var m_ingredientFields:Array;
      
      public function PurchaseBushelBundles(recipe:RecipeItem, sharedCallBack:Function, maximum:int = 99)
      {
         var showOnlyCompleted:Boolean = false;
         var isUnlocked:Boolean = false;
         this.m_ingredientFields = new Array();
         var failoverEntryArray:Array = new Array(new ZLocFailoverEntry(null,recipe.friendlyName + "_recipe"),new ZLocFailoverEntry(null,recipe.friendlyName));
         var recipeName:String = ZLocUtils.getFailoverLocString(failoverEntryArray);
         var iconUrl:String = recipe.image;
         if(recipe.recipeType == CraftingConstants.LABTYPE_RECIPE)
         {
            showOnlyCompleted = LabBuildingManager.getInstance().shouldLabShowOnlyCompleted(recipe.craft);
            if(showOnlyCompleted)
            {
               isUnlocked = Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.LAB_BUILDING,recipe.productItemCode));
               if(!isUnlocked)
               {
                  iconUrl = LabBuildingManager.getInstance().getMysteryIcon(recipe.craft);
                  recipeName = ZLocUtils.t("Crafting",recipe.craft + "_unknown_recipe");
               }
            }
         }
         var message:String = "";
         if(recipe.recipeType == CraftingConstants.LABTYPE_RECIPE)
         {
            message = ZLocUtils.t("Crafting","BushelBundleBuyBody",{
               "recipe":recipeName,
               "ingredient":ZLocUtils.t("Crafting",recipe.craft + "_ingredient")
            });
         }
         else
         {
            message = ZLocUtils.t("Crafting","BushelBundleBuyBody",{
               "recipe":recipeName,
               "ingredient":ZLocUtils.t("Crafting","craftshop_ingredient")
            });
         }
         super({
            "icon":Global.getAssetURL(iconUrl),
            "friendlyName":recipe.friendlyName,
            "code":recipe.productItemCode
         },sharedCallBack,message,maximum,this.ASSET_DIALOG_v2);
         m_units = ZLocUtils.t("Crafting","BushelBundleBuyPreview",{
            "quantity":1,
            "setword":ZLocUtils.tk("Crafting","BushelBundleBuySet","",1)
         });
         this.m_recipe = recipe;
         this.m_bundleCost = CraftingManager.getInstance().getTotalBushelPrice(this.m_recipe);
      }
      
      override protected function postLoadComplete() : void
      {
         var ingredient_tf:ZwTextField = null;
         var ingredientName:String = null;
         var ingredientNameTK:String = null;
         var ingredient:Object = null;
         LoadingManager.load(m_item.icon,onIconLoaded);
         addWidget(new ZwFrame(m_window.popupBox_mc));
         var bodyTextField:ZwTextField = new ZwTextField(m_window.popupBox_mc.popupBox_tf,m_bodyText);
         var textFormat:TextFormat = bodyTextField.getTextFormat();
         textFormat.align = "center";
         bodyTextField.setTextFormat(textFormat);
         addWidget(bodyTextField);
         var idx:int = 1;
         for each(ingredient in this.m_recipe.ingredients)
         {
            if(!(ingredient.hasOwnProperty(RecipeItem.SWAPPABLE) && ingredient[RecipeItem.SWAPPABLE] == true))
            {
               ingredientNameTK = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode).friendlyName;
               ingredientName = ZLocUtils.t("Crafting","BushelBundleBuyIngredient",{
                  "quantity":ingredient.quantityRequired,
                  "ingredient":ZLocUtils.tk_pk(ingredientNameTK,"",ingredient.quantityRequired)
               });
               ingredient_tf = new ZwTextField(m_window.popupBox_mc.getChildByName("crop" + idx + "_tf"),ingredientName);
               addWidget(ingredient_tf);
               this.m_ingredientFields.push(ingredient_tf);
               idx++;
            }
         }
         addWidget(new ZwFrame(m_window.popupBox_mc.farmCashIcon_mc));
         m_iconFrame = new ZwFrame(m_window.popupBox_mc.icon_mc);
         addWidget(m_iconFrame);
         m_iconFrame.y -= 20;
         addWidget(new ZwFrame(m_window.popupBox_mc.bouquets_mc));
         this.m_amountTextField = new ZwTextField(m_window.popupBox_mc.bouquets_mc.bouquets_tf,m_units);
         addWidget(this.m_amountTextField);
         m_quantityTextField = new ZwTextField(m_window.popupBox_mc.amount_tf,"");
         addWidget(m_quantityTextField);
         addWidget(new ZwButton(m_window.popupBox_mc.bouquets_mc.arrowUp_bt,this.onUpArrowClick));
         addWidget(new ZwButton(m_window.popupBox_mc.bouquets_mc.arrowDown_bt,this.onDownArrowClick));
         this.displayQuantity(1);
         m_window.popupBox_mc.okay_bt.visible = true;
         m_accept = new GenericButton(m_window.popupBox_mc.okay_bt,this.onShareClicked);
         m_accept.text = ZLocUtils.t("Dialogs","Buy");
         m_window.popupBox_mc.cancel_bt.visible = true;
         m_reject = new GenericButton(m_window.popupBox_mc.cancel_bt,onCancelClicked);
         m_reject.text = ZLocUtils.t("Dialogs","Cancel");
      }
      
      private function setRecipeText() : void
      {
         var ingredientName:String = null;
         var ingredientNameTK:String = null;
         var ingredient:Object = null;
         var quantity:int = 0;
         var idx:int = 1;
         var multiplier:int = this.currentQuantitySelected;
         for each(ingredient in this.m_recipe.ingredients)
         {
            if(!(ingredient.hasOwnProperty(RecipeItem.SWAPPABLE) && ingredient[RecipeItem.SWAPPABLE] == true))
            {
               quantity = ingredient.quantityRequired * multiplier;
               ingredientNameTK = Global.farmGameSettingsManager.getFarmItemByCode(ingredient.itemCode).friendlyName;
               ingredientName = ZLocUtils.t("Crafting","BushelBundleBuyIngredient",{
                  "quantity":quantity,
                  "ingredient":ZLocUtils.tk_pk(ingredientNameTK,"",quantity)
               });
               (this.m_ingredientFields[idx - 1] as ZwTextField).text = ingredientName;
               idx++;
            }
         }
      }
      
      override protected function onUpArrowClick(e:MouseEvent) : void
      {
         var amount:int = this.currentQuantitySelected + 1 <= m_maxValue ? int(this.currentQuantitySelected + 1) : m_maxValue;
         this.displayQuantity(amount);
      }
      
      override protected function onDownArrowClick(e:MouseEvent) : void
      {
         var amount:int = this.currentQuantitySelected - 1 > 1 ? int(this.currentQuantitySelected - 1) : 1;
         this.displayQuantity(amount);
      }
      
      override protected function displayQuantity(value:int) : void
      {
         m_quantityTextField.text = (value * this.m_bundleCost).toString();
         this.m_amountTextField.text = ZLocUtils.t("Crafting","BushelBundleBuyPreview",{
            "quantity":value,
            "setword":ZLocUtils.tk("Crafting","BushelBundleBuySet","",value)
         });
         this.setRecipeText();
      }
      
      override protected function get currentQuantitySelected() : int
      {
         return int(m_quantityTextField.text) / this.m_bundleCost;
      }
      
      override protected function onShareClicked(event:MouseEvent) : void
      {
         if(this.m_SharedCallBack != null)
         {
            m_SharedCallBack(this.m_recipe.id,this.currentQuantitySelected);
         }
         close();
      }
      
      override protected function release() : void
      {
         super.release();
         m_isOpen = false;
         this.m_ingredientFields = null;
         CraftingManager.getInstance().onClosePurchaseDialog();
      }
   }
}

