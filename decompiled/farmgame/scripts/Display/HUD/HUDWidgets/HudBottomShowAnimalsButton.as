package Display.HUD.HUDWidgets
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.ItemFinderManager;
   import Managers.OlyInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   
   public class HudBottomShowAnimalsButton extends HUDWidget
   {
      
      private static const HUD_MC:String = "hud_mc";
      
      private var x_offset:int = 80;
      
      private var y_offset:int = 120;
      
      private var m_featureName:String;
      
      private var m_animalType:String;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_state:int = -1;
      
      private const TEXT_FIND_ANIMALS_BTN_TOOLTIP1:String = "_FindAnimalsBtn_t1";
      
      private const TEXT_FIND_ANIMALS_BTN_TOOLTIP2:String = "_FindAnimalsBtn_t2";
      
      public function HudBottomShowAnimalsButton(assetPath:String, featureName:String, animalType:String, X_Offset:int = 80, Y_Offset:int = 120)
      {
         super(assetPath,Global.hud);
         this.m_featureName = featureName;
         this.m_animalType = animalType;
         this.x_offset = X_Offset;
         this.y_offset = Y_Offset;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var description:String = null;
         super.onLoadComplete(event);
         m_element.filters = [new DropShadowFilter()];
         this.setXY();
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         if(m_element.hasOwnProperty(HUD_MC))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element[HUD_MC],this.showAnimals),true);
            description = ZLocUtils.t("Dialogs",this.m_featureName + "_find" + this.m_animalType);
            this.m_hudButton.attachTooltip(new FarmTextTooltip(description));
            this.m_hudButton.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.m_hudButton.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
      }
      
      private function onMouseOver(e:Event) : void
      {
         if(this.m_hudButton)
         {
            m_element.filters = [new GlowFilter(16777113,1,14,14,1.83)];
         }
      }
      
      private function onMouseOut(e:Event) : void
      {
         if(this.m_hudButton)
         {
            m_element.filters = [new DropShadowFilter()];
         }
      }
      
      private function showAnimals(event:Event) : void
      {
         var itemsArray:Array = OlyInnovationManager.getInstance().getItemsByType(this.m_animalType);
         if(ItemFinderManager.getInstance().atleastOneItemPlacedOnWorld(itemsArray))
         {
            OlyInnovationManager.getInstance().highlightItemsOfType(this.m_animalType);
         }
         else if(ItemFinderManager.getInstance().atleastOneItemInGiftBox(itemsArray))
         {
            UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FIND_ANIMALS_BTN_TOOLTIP1),GenericPopup.TYPE_OK);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_FIND_ANIMALS_BTN_TOOLTIP2),GenericPopup.TYPE_OK);
         }
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - this.x_offset;
            m_loader.y = Global.stage.stageHeight - this.y_offset;
         }
      }
      
      public function refresh(state:int) : void
      {
         if(state != this.m_state)
         {
            this.m_state = state;
         }
      }
      
      override public function release() : void
      {
         this.m_hudButton = null;
         super.release();
      }
   }
}

