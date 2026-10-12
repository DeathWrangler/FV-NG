package Widgets.Windows
{
   import Engine.Utilities;
   import Managers.FreezeManager;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class TutorialAnimatedWindow extends FarmWindow
   {
      
      private static const ANIMATION_TIME:int = 333;
      
      private var m_lastTime:int;
      
      private var m_currentInterp:Number = 0;
      
      private var m_targetInterp:Number = 0;
      
      private var m_startHalfSize:Point;
      
      private var m_isClosing:Boolean = false;
      
      public function TutorialAnimatedWindow(windowAssetRelUrl:String)
      {
         super(windowAssetRelUrl);
         this.m_lastTime = GlobalEngine.currentTime;
         this.m_currentInterp = 0;
         this.m_targetInterp = 0;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_startHalfSize = new Point(m_loader.content.width / 2,m_loader.content.height / 2);
      }
      
      override public function close() : void
      {
         var dispObj:DisplayObject = this;
         this.m_lastTime = GlobalEngine.currentTime;
         this.m_targetInterp = 0;
         this.m_isClosing = true;
         onHide();
      }
      
      override public function show() : void
      {
         if(m_isLoaded)
         {
            if(shouldFreeze)
            {
               FreezeManager.freezeRender();
            }
            this.m_lastTime = GlobalEngine.currentTime;
            this.m_targetInterp = 1;
            centerPopup();
            onShow();
         }
         else
         {
            m_showOnLoad = true;
         }
      }
      
      override public function hide() : void
      {
         this.m_lastTime = GlobalEngine.currentTime;
         this.m_targetInterp = 0;
         this.m_isClosing = false;
         onHide();
      }
      
      public function enterFrame() : void
      {
         var deltaAmount:Number = NaN;
         if(this.m_currentInterp != this.m_targetInterp)
         {
            deltaAmount = (GlobalEngine.currentTime - this.m_lastTime) / ANIMATION_TIME;
            this.m_lastTime = GlobalEngine.currentTime;
            if(this.m_targetInterp < this.m_currentInterp)
            {
               this.m_currentInterp = Math.max(this.m_currentInterp - deltaAmount,this.m_targetInterp);
               if(this.m_targetInterp == this.m_currentInterp)
               {
                  if(this.m_isClosing)
                  {
                     release();
                     dispatchEvent(new Event(Event.CLOSE));
                  }
               }
            }
            else
            {
               this.m_currentInterp = Math.min(this.m_currentInterp + deltaAmount,this.m_targetInterp);
               if(this.m_targetInterp == this.m_currentInterp)
               {
                  Utilities.toggleInputAndChildren(this,true);
               }
            }
            this.updateMatrix(this.m_currentInterp);
         }
      }
      
      private function updateMatrix(interpIn:Number) : void
      {
         var interp:Number = NaN;
         var mat:Matrix = null;
         if(Boolean(m_loader) && Boolean(m_loader.content))
         {
            interp = Math.sin(interpIn * Math.PI / 2);
            if(interp == 0)
            {
               this.visible = false;
            }
            else
            {
               this.visible = true;
            }
            mat = new Matrix();
            mat.translate(-this.m_startHalfSize.x,-this.m_startHalfSize.y);
            mat.scale(interp,interp);
            mat.translate(this.m_startHalfSize.x,this.m_startHalfSize.y);
            m_loader.content.transform.matrix = mat;
         }
      }
   }
}

