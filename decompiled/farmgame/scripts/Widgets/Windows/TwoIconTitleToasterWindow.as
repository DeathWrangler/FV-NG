package Widgets.Windows
{
   import Display.GenericPopup;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFieldAutoSize;
   
   public class TwoIconTitleToasterWindow extends AutoCloseToasterWindow
   {
      
      private static var CLOSE:String = "TwoIconTitleToasterWindow_Close";
      
      private const DIALOG_ASSET:String = "assets/dialogs/FV_BannerAd_Rewards_generic.swf";
      
      protected var m_title:String;
      
      protected var m_text:String;
      
      protected var m_iconUrl:String;
      
      protected var m_icon2Url:String;
      
      protected var m_iconScale:Number = 1;
      
      protected var m_icon2Scale:Number = 1;
      
      protected var m_iconOffset:Point = null;
      
      protected var m_icon2Offset:Point = null;
      
      protected var m_stars_enabled:Boolean = true;
      
      protected var m_clickCallback:Function = null;
      
      protected var m_closeCallback:Function;
      
      protected var m_infoButton:Boolean = false;
      
      protected var m_infoText:String = null;
      
      protected var m_actionButtonText:String = null;
      
      public function TwoIconTitleToasterWindow(title:String, text:String, iconUrl:String, icon2Url:String, windowAssetPath:String = "assets/dialogs/FV_BannerAd_Rewards_generic.swf", iconScale:Number = 1, icon2Scale:Number = 1, iconOffset:Point = null, icon2Offset:Point = null, clickCallback:Function = null, stars:Boolean = true, infoButton:Boolean = false, moreInfoText:String = null, closeCallback:Function = null, actionButtonText:String = null, toasterTTL:Number = 0)
      {
         super(windowAssetPath);
         this.m_title = title;
         this.m_text = text;
         this.m_iconUrl = iconUrl;
         this.m_iconScale = iconScale;
         this.m_iconOffset = iconOffset;
         this.m_icon2Url = icon2Url;
         this.m_icon2Scale = icon2Scale;
         this.m_icon2Offset = icon2Offset;
         this.m_clickCallback = clickCallback;
         this.m_stars_enabled = stars;
         this.m_infoButton = infoButton;
         this.m_infoText = moreInfoText;
         this.m_closeCallback = closeCallback;
         this.m_actionButtonText = actionButtonText;
         if(toasterTTL > 0)
         {
            m_timeToLive = toasterTTL;
         }
         if(this.m_closeCallback != null)
         {
            addEventListener(TwoIconTitleToasterWindow.CLOSE,this.m_closeCallback);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var frame:ZwFrame = new ZwFrame(m_window.bannerad_mc);
         var usedLineCount:int = 0;
         for(var lineCtr:int = 0; lineCtr < m_window.bannerad_mc.generic_desc_tf.numLines; lineCtr++)
         {
            if(m_window.bannerad_mc.generic_desc_tf.getLineLength(lineCtr) > 0)
            {
               usedLineCount++;
            }
         }
         if(usedLineCount == 1)
         {
            m_window.bannerad_mc.generic_desc_tf.y = m_window.bannerad_mc.generic_desc_tf.getLineMetrics(0).height * 2;
         }
         else if(usedLineCount == 2)
         {
            m_window.bannerad_mc.generic_desc_tf.y = m_window.bannerad_mc.generic_desc_tf.getLineMetrics(0).height * 1.5;
         }
         frame.addWidget(new ZwButton(m_window.bannerad_mc.close_bt,onClose));
         m_window.bannerad_mc.generic_desc_tf.autoSize = TextFieldAutoSize.CENTER;
         frame.addWidget(new ZwTextField(m_window.bannerad_mc.generic_tf,this.m_title));
         frame.addWidget(new ZwTextField(m_window.bannerad_mc.generic_desc_tf,this.m_text));
         if(this.m_actionButtonText)
         {
            frame.addWidget(new FarmAnimatedTextButton(m_window.bannerad_mc.buy_bt,this.m_actionButtonText));
         }
         frame.addWidget(new FarmIcon(m_window.bannerad_mc.icon_mc,this.m_iconUrl));
         if(this.m_infoButton && this.m_infoText != null)
         {
            frame.addWidget(new ZwButton(m_window.bannerad_mc.info_bt,this.moreInfoPopup));
         }
         m_window.bannerad_mc.icon_mc.scaleX = this.m_iconScale;
         m_window.bannerad_mc.icon_mc.scaleY = this.m_iconScale;
         if(this.m_iconOffset != null)
         {
            m_window.bannerad_mc.icon_mc.x += this.m_iconOffset.x;
            m_window.bannerad_mc.icon_mc.y += this.m_iconOffset.y;
         }
         frame.addWidget(new FarmIcon(m_window.bannerad_mc.icon2_mc,this.m_icon2Url));
         m_window.bannerad_mc.icon2_mc.scaleX = this.m_icon2Scale;
         m_window.bannerad_mc.icon2_mc.scaleY = this.m_icon2Scale;
         if(this.m_icon2Offset != null)
         {
            m_window.bannerad_mc.icon2_mc.x += this.m_icon2Offset.x;
            m_window.bannerad_mc.icon2_mc.y += this.m_icon2Offset.y;
         }
         if(this.m_stars_enabled == true)
         {
            frame.addWidget(new ZwFrame(m_window.bannerad_mc.stars_mc));
         }
         addWidget(frame);
         if(this.m_clickCallback != null)
         {
            frame.registerEventListener(MouseEvent.CLICK,this.m_clickCallback);
         }
      }
      
      private function moreInfoPopup(event:MouseEvent) : void
      {
         var popUp:GenericPopup = new GenericPopup(this.m_infoText,GenericPopup.TYPE_OK);
         UI.displayPopup(popUp,true);
      }
      
      override public function close() : void
      {
         if(m_showTween)
         {
            hideTween(function():void
            {
               if(m_closeCallback != null)
               {
                  dispatchEvent(new Event(TwoIconTitleToasterWindow.CLOSE));
                  removeEventListener(TwoIconTitleToasterWindow.CLOSE,m_closeCallback);
               }
               release();
               dispatchEvent(new Event(Event.CLOSE));
            });
            onHide();
         }
         else
         {
            onHide();
            release();
            dispatchEvent(new Event(Event.CLOSE));
         }
      }
   }
}

