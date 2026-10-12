package Display.HUD.HUDWidgets
{
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   
   public class HUDBottomTutorialButton extends HUDWidget
   {
      
      private static const X_OFFSET:int = 80;
      
      private static const Y_OFFSET:int = 120;
      
      private var m_hudButton:FarmAnimatedButton;
      
      private var m_dialogKey:String;
      
      private var m_featureName:String;
      
      private var m_xoffset:int;
      
      private var m_yoffset:int;
      
      private var m_addGlow:Boolean;
      
      public function HUDBottomTutorialButton(assetPath:String, dialogKey:String, featureName:String, Xoffset:int = 80, Yoffset:int = 120, addGlow:Boolean = false)
      {
         super(assetPath,Global.hud);
         this.m_dialogKey = dialogKey;
         this.m_featureName = featureName;
         if(Xoffset != 0)
         {
            this.m_xoffset = Xoffset;
         }
         else
         {
            this.m_xoffset = X_OFFSET;
         }
         if(Yoffset != 0)
         {
            this.m_yoffset = Yoffset;
         }
         else
         {
            this.m_yoffset = Y_OFFSET;
         }
         this.m_addGlow = addGlow;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var description:String = null;
         super.onLoadComplete(event);
         this.setXY();
         var parentFrame:ZwFrame = new ZwFrame(m_element);
         (parentFrame.element as MovieClip).stop();
         m_element.filters = [new DropShadowFilter()];
         if(m_element.hasOwnProperty("hud_mc"))
         {
            addWidget(this.m_hudButton = new FarmAnimatedButton(m_element.hud_mc,this.startFTUE),true);
            description = ZLocUtils.t_pk("Dialogs",this.m_dialogKey);
            this.m_hudButton.attachTooltip(new FarmTextTooltip(description));
            this.m_hudButton.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.m_hudButton.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
      }
      
      private function onMouseOver(e:Event) : void
      {
         if(this.m_addGlow && Boolean(this.m_hudButton))
         {
            m_element.filters = [new GlowFilter(16777113,1,14,14,1.83)];
         }
      }
      
      private function onMouseOut(e:Event) : void
      {
         if(this.m_addGlow && Boolean(this.m_hudButton))
         {
            m_element.filters = [new DropShadowFilter()];
         }
      }
      
      private function startFTUE(event:Event) : void
      {
         HUDTutorialManager.instance.initialize(this.m_featureName,null,true);
      }
      
      public function setXY() : void
      {
         if(m_loader)
         {
            m_loader.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - this.m_xoffset;
            m_loader.y = Global.stage.stageHeight - this.m_yoffset;
         }
      }
   }
}

