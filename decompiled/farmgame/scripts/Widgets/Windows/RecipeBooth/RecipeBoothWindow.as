package Widgets.Windows.RecipeBooth
{
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.RecipeBoothManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Frames.RecipeBooth.RecipeBoothIngredientSlotContainerFrame;
   import Widgets.Frames.RecipeBooth.RecipeBoothItemSlotContainerFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class RecipeBoothWindow extends FarmWindow
   {
      
      private var m_loadingWidget:ZwWidget;
      
      private var m_building:FeatureBuilding;
      
      private var m_gameSettings:Object;
      
      private var m_howDoesThisWorkButton:FarmAnimatedTextButton;
      
      private var m_itemSlots:RecipeBoothItemSlotContainerFrame;
      
      private var m_ingredientSlots:RecipeBoothIngredientSlotContainerFrame;
      
      private var m_ingredientTextField:FarmTextField;
      
      private var m_submitButton:FarmAnimatedTextButton;
      
      public function RecipeBoothWindow(building:FeatureBuilding)
      {
         var dialogAssetUrl:String = null;
         RecipeBoothManager.currentContentsWindow = this;
         this.m_building = building;
         var dialogConfig:Object = this.m_building.getItem().getDialogConfig("storage");
         if(Boolean(dialogConfig) && Boolean(dialogConfig["path"]))
         {
            dialogAssetUrl = dialogConfig["path"];
         }
         if(dialogAssetUrl)
         {
            super(dialogAssetUrl);
         }
         else
         {
            GlobalEngine.assert(false,"Building item xml is missing dialog config information.");
         }
      }
      
      public static function display(building:FeatureBuilding) : RecipeBoothWindow
      {
         var window:RecipeBoothWindow = null;
         if(building)
         {
            window = new RecipeBoothWindow(building);
            UI.displayPopup(window,true,"RecipeBoothWindow",true);
            FarmStatsManager.sample(100,building.getItemName(),"open");
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         this.m_loadingWidget = addWidget(new ZwWidget(m_window.mc_loader),false) as ZwWidget;
         this.m_howDoesThisWorkButton = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.onHowDoesThisWorkClick)) as FarmAnimatedTextButton;
         addWidget(new FarmTextField(m_window.title_tf,this.m_building.getItem().friendlyTitle));
         var infoTextKey:String = this.featureName + "_InfoMessage";
         var infoText:String = ZLocUtils.hasString("Dialogs",infoTextKey) ? ZLocUtils.t("Dialogs",infoTextKey) : "";
         if(infoText)
         {
            addWidget(new FarmTextField(m_window.header_tf,infoText));
         }
         var submitButtonTextKey:String = this.featureName + "_SubmitButton";
         var submitButtonText:String = ZLocUtils.hasString("Dialogs",submitButtonTextKey) ? ZLocUtils.t("Dialogs",submitButtonTextKey) : "Dialogs:" + submitButtonTextKey;
         this.m_submitButton = addWidget(new FarmAnimatedTextButton(m_window.submit_mc,submitButtonText,this.onSubmitButtonClick)) as FarmAnimatedTextButton;
         this.m_submitButton.enabled = false;
         this.m_itemSlots = addWidget(new RecipeBoothItemSlotContainerFrame(m_window.slots_mc)) as RecipeBoothItemSlotContainerFrame;
         this.m_ingredientSlots = addWidget(new RecipeBoothIngredientSlotContainerFrame(m_window.cards_mc)) as RecipeBoothIngredientSlotContainerFrame;
         this.m_ingredientTextField = addWidget(new FarmTextField(m_window.subheader_tf," ")) as FarmTextField;
         this.m_gameSettings = RecipeBoothManager.getGameSettings(this.featureName);
         if(this.m_gameSettings)
         {
            this.refresh();
         }
         else
         {
            this.showLoadingWidget();
         }
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         this.m_gameSettings = null;
         if(RecipeBoothManager.currentContentsWindow == this)
         {
            RecipeBoothManager.currentContentsWindow = null;
         }
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_closeButton.enabled)
         {
            super.onClose(event);
         }
      }
      
      public function get building() : FeatureBuilding
      {
         return this.m_building;
      }
      
      public function get featureName() : String
      {
         return this.m_building ? this.m_building.getItemName() : "";
      }
      
      public function get batchName() : String
      {
         return this.m_gameSettings ? this.m_gameSettings["batchName"] : "";
      }
      
      public function set gameSettings(value:Object) : void
      {
         this.m_gameSettings = value;
         this.refresh();
      }
      
      public function get gameSettings() : Object
      {
         return this.m_gameSettings;
      }
      
      public function refresh() : void
      {
         var tutorialSeenFlag:String = null;
         if(m_window)
         {
            this.hideLoadingWidget();
            tutorialSeenFlag = this.featureName + "_Tutorial";
            if(!Global.player.getSeenFlag(tutorialSeenFlag))
            {
               Global.player.setSeenFlag(tutorialSeenFlag);
               this.showTutorialWindow();
            }
            this.m_itemSlots.items = this.m_gameSettings[RecipeBoothManager.KEY_LOOT_ITEMS];
            this.m_ingredientSlots.items = this.m_gameSettings[RecipeBoothManager.KEY_INGREDIENTS];
            this.refreshSubmitButton();
         }
      }
      
      public function refreshAskButtons() : void
      {
         if(this.m_ingredientSlots)
         {
            this.m_ingredientSlots.refreshAskButtons();
         }
      }
      
      public function refreshSubmitButton() : void
      {
         var hasEnoughIngredients:Boolean = false;
         var ingredientTextKey:String = null;
         var ingredientText:String = null;
         if(this.m_submitButton)
         {
            hasEnoughIngredients = this.m_ingredientSlots.hasEnough;
            this.m_submitButton.enabled = hasEnoughIngredients;
            ingredientTextKey = this.featureName + (hasEnoughIngredients ? "_IngredientMessage_Default" : "_IngredientMessage_NotEnough");
            ingredientText = ZLocUtils.hasString("Dialogs",ingredientTextKey) ? ZLocUtils.t("Dialogs",ingredientTextKey) : "";
            if(ingredientText)
            {
               this.m_ingredientTextField.text = ingredientText;
            }
         }
      }
      
      private function showLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(Boolean(this.m_loadingWidget) && !this.m_loadingWidget.visible)
         {
            this.m_loadingWidget.visible = true;
            element = this.m_loadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.gotoAndPlay(1);
               }
            }
         }
      }
      
      private function hideLoadingWidget() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         if(Boolean(this.m_loadingWidget) && this.m_loadingWidget.visible)
         {
            this.m_loadingWidget.visible = false;
            element = this.m_loadingWidget.element as MovieClip;
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(child)
               {
                  child.stop();
               }
            }
         }
      }
      
      private function onHowDoesThisWorkClick(event:Event) : void
      {
         this.showTutorialWindow();
      }
      
      private function showTutorialWindow() : void
      {
         var prefixUrl:String = this.m_building.getItem().prefixUrl;
         TutorialUI.displayBuildingTutorialWindow(this.m_building,prefixUrl,false,null);
      }
      
      private function onSubmitButtonClick(event:MouseEvent) : void
      {
         if(this.m_submitButton.enabled)
         {
            this.m_submitButton.enabled = false;
            enableInput = false;
            tintWindow();
            RecipeBoothManager.sendMakeRecipeTransaction(this.featureName,this.batchName,this.m_ingredientSlots.counts);
            this.m_ingredientSlots.deductCounts();
            FarmStatsManager.count(this.featureName,"makeRecipe","submit");
         }
      }
      
      public function handleRedemptionResult(result:Object) : void
      {
         if(m_window)
         {
            this.refresh();
         }
      }
      
      public function onMakeRecipeResultWindowClose() : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
         }
      }
   }
}

