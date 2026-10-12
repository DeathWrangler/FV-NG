package Widgets.Windows
{
   import Classes.util.MovieClipUtils;
   import Managers.PerformanceExperimentManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import com.greensock.TweenLite;
   import flash.events.MouseEvent;
   
   public class ArrowIndicatorWindow extends StateIndicatorWindow
   {
      
      private const DIALOG_ASSET:String = "assets/dialogs/FV_Craft_indicator.swf";
      
      private const ICON_SIZE:int = 50;
      
      protected var m_counterText:String;
      
      protected var m_textVisible:Boolean = false;
      
      private var m_icon:FarmIcon;
      
      private var m_counterTextField:ZwTextField;
      
      private var m_closeOutCallback:Function;
      
      private var m_closeOverCallback:Function;
      
      private var m_xButtonActive:Boolean = false;
      
      public function ArrowIndicatorWindow(iconUrl:String, title:String, text:String, counterText:String = null, textVisible:Boolean = false, dialogAsset:String = "assets/dialogs/FV_Craft_indicator.swf")
      {
         super(dialogAsset,iconUrl,title,text);
         this.m_counterText = counterText;
         this.m_textVisible = textVisible;
      }
      
      override protected function postLoadComplete() : void
      {
         var counterFrame:ZwFrame = null;
         super.postLoadComplete();
         var mainFrame:ZwFrame = new ZwFrame(m_window.arrowBounce_mc);
         this.m_icon = mainFrame.addWidget(new FarmIcon(m_window.arrowBounce_mc.icon_mc,m_iconUrl)) as FarmIcon;
         this.m_icon.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
         this.m_icon.setSmoothing(true);
         var bouncingArrow:ZwWidget = new ZwWidget(m_window.arrowBounce_mc.arrow_mc);
         mainFrame.addWidget(bouncingArrow);
         this.setupAnimation();
         m_window.arrowBounce_mc.box_mc.visible = true;
         m_window.arrowBounce_mc.hitBox_bt.visible = true;
         var textRolloverFrame:ZwFrame = this.buildTextFrame();
         if(textRolloverFrame)
         {
            mainFrame.addWidget(textRolloverFrame,true);
         }
         if(this.m_counterText)
         {
            counterFrame = new ZwFrame(m_window.arrowBounce_mc.counterBox_mc);
            this.m_counterTextField = new ZwTextField(m_window.arrowBounce_mc.counter_tf,this.m_counterText);
            counterFrame.addWidget(this.m_counterTextField);
            mainFrame.addWidget(counterFrame);
         }
         if(m_window.hasOwnProperty("boxRollover_mc"))
         {
            if(!this.m_xButtonActive)
            {
               m_window.arrowBounce_mc.boxRollover_mc.close_bt.visible = false;
            }
            else
            {
               m_window.arrowBounce_mc.boxRollover_mc.close_bt.visible = true;
               m_window.arrowBounce_mc.boxRollover_mc.close_bt.addEventListener(MouseEvent.MOUSE_OVER,this.m_closeOverCallback);
               m_window.arrowBounce_mc.boxRollover_mc.close_bt.addEventListener(MouseEvent.MOUSE_OUT,this.m_closeOutCallback);
            }
         }
         addWidget(mainFrame);
         if(Global.worldManager.isVisiting())
         {
         }
      }
      
      override public function get iconUrl() : String
      {
         return m_iconUrl;
      }
      
      override public function set iconUrl(value:String) : void
      {
         m_iconUrl = value;
         if(Boolean(this.m_icon) && Boolean(m_iconUrl))
         {
            this.m_icon.loadIcon(m_iconUrl);
         }
      }
      
      public function setupCloseButton(overCallbackFunction:Function, outCallBackFunction:Function) : void
      {
         this.m_closeOverCallback = overCallbackFunction;
         this.m_closeOutCallback = outCallBackFunction;
         if(m_window != null)
         {
            m_window.arrowBounce_mc.boxRollover_mc.close_bt.visible = true;
            m_window.arrowBounce_mc.boxRollover_mc.close_bt.addEventListener(MouseEvent.MOUSE_OVER,this.m_closeOverCallback);
            m_window.arrowBounce_mc.boxRollover_mc.close_bt.addEventListener(MouseEvent.MOUSE_OUT,this.m_closeOutCallback);
         }
         this.m_xButtonActive = true;
      }
      
      public function destroyCloseButton() : void
      {
         if(this.m_closeOverCallback != null && this.m_closeOutCallback != null && m_window != null)
         {
            m_window.arrowBounce_mc.boxRollover_mc.close_bt.removeEventListener(MouseEvent.MOUSE_OVER,this.m_closeOverCallback);
            m_window.arrowBounce_mc.boxRollover_mc.close_bt.removeEventListener(MouseEvent.MOUSE_OUT,this.m_closeOutCallback);
            this.m_closeOverCallback = null;
            this.m_closeOutCallback = null;
         }
         this.m_xButtonActive = false;
      }
      
      protected function setupAnimation() : void
      {
         if(PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
         {
            MovieClipUtils.recursiveStop(m_window.arrowBounce_mc);
         }
         else
         {
            m_window.arrowBounce_mc.gotoAndPlay(0);
         }
      }
      
      protected function buildTextFrame() : ZwFrame
      {
         var textFrame:ZwFrame = null;
         if(Boolean(m_title && m_text) && Boolean(m_window.hasOwnProperty("arrowBounce_mc")) && Boolean(m_window.arrowBounce_mc.hasOwnProperty("boxRollover_mc")))
         {
            textFrame = new ZwFrame(m_window.arrowBounce_mc.boxRollover_mc);
            textFrame.addWidget(new ZwTextField(m_window.arrowBounce_mc.boxRollover_mc.generic1_tf,m_title));
            textFrame.addWidget(new ZwTextField(m_window.arrowBounce_mc.boxRollover_mc.generic2_tf,m_text));
            textFrame.alpha = this.m_textVisible ? 1 : 0;
         }
         return textFrame;
      }
      
      public function toggleText(visible:Boolean) : void
      {
         var textFrame:ZwFrame = null;
         var mainFrame:ZwFrame = getWidget(m_window.arrowBounce_mc) as ZwFrame;
         if(mainFrame)
         {
            textFrame = mainFrame.getWidget(m_window.arrowBounce_mc.boxRollover_mc) as ZwFrame;
            if(textFrame)
            {
               textFrame.alpha = this.m_textVisible ? 1 : 0;
            }
         }
      }
      
      public function updateCounter(count:String) : void
      {
         if(Boolean(this.m_counterText) && Boolean(count) && this.m_counterText != count)
         {
            this.m_counterText = count;
            this.m_counterTextField.text = count;
         }
      }
      
      public function showRolloverText(isShow:Boolean) : void
      {
         var mainFrame:ZwFrame = null;
         var textFrame:ZwFrame = null;
         var scl:Number = NaN;
         if(m_window)
         {
            mainFrame = getWidget(m_window.arrowBounce_mc) as ZwFrame;
            if(mainFrame)
            {
               textFrame = mainFrame.getWidget(m_window.arrowBounce_mc.boxRollover_mc) as ZwFrame;
               if(textFrame)
               {
                  if(PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment)
                  {
                     textFrame.alpha = isShow ? 1 : 0;
                     MovieClipUtils.recursiveStop(m_window.arrowBounce_mc);
                  }
                  else
                  {
                     textFrame.alpha = isShow ? 0 : 1;
                     TweenLite.to(textFrame,0.2,{"alpha":(isShow ? 1 : 0)});
                  }
                  scl = 2 / GlobalEngine.viewport.getZoom();
                  m_window.arrowBounce_mc.boxRollover_mc.scaleX = scl;
                  m_window.arrowBounce_mc.boxRollover_mc.scaleY = scl;
               }
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_icon = null;
         this.m_counterTextField = null;
         super.release();
      }
   }
}

