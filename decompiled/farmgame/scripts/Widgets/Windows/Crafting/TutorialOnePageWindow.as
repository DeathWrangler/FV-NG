package Widgets.Windows.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.TutorialOnePageSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class TutorialOnePageWindow extends FarmWindow
   {
      
      private const FAQ_MC:String = "faq_mc";
      
      private var m_items:Array;
      
      private var m_title:String;
      
      private var m_version2:Boolean;
      
      private var m_buttonText:String;
      
      private var m_hideCloseButton:Boolean;
      
      private var m_faqTf:FarmAnimatedButton;
      
      private var m_faqLink:String;
      
      public function TutorialOnePageWindow(items:Array, title:String, version2:Boolean, buttonText:String = null, hideCloseButton:Boolean = false, faqLink:String = "")
      {
         super("assets/dialogs/FV_Tutorial_onePage.swf");
         this.m_items = items;
         this.m_title = title;
         this.m_version2 = version2;
         if(buttonText != null)
         {
            this.m_buttonText = buttonText;
         }
         else
         {
            this.m_buttonText = ZLocUtils.t("Crafting","General_Okay");
         }
         this.m_hideCloseButton = hideCloseButton;
         this.m_faqLink = faqLink;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,this.m_title));
         addWidget(new FarmAnimatedTextButton(m_window.okay_bt,this.m_buttonText,onClose));
         addWidget(new TutorialOnePageSlotFrame(m_window.mainFrame_mc,this.m_items));
         if(this.m_version2 && Boolean(m_window.version2_mc))
         {
            addWidget(new ZwWidget(m_window.version2_mc));
         }
         if(m_window.hasOwnProperty(this.FAQ_MC))
         {
            if(this.m_faqLink != "")
            {
               this.m_faqTf = addWidget(new FarmAnimatedButton(m_window[this.FAQ_MC],this.onFAQClick)) as FarmAnimatedButton;
            }
            else
            {
               (m_window[this.FAQ_MC] as DisplayObject).visible = false;
            }
         }
      }
      
      private function onFAQClick(event:MouseEvent) : void
      {
         if(this.m_faqLink != "")
         {
            navigateToURL(new URLRequest(this.m_faqLink),"_blank");
         }
      }
      
      override protected function release() : void
      {
         if(this.m_faqTf)
         {
            this.m_faqTf.removeEventListener(MouseEvent.CLICK,this.onFAQClick);
         }
         super.release();
         this.m_items = null;
      }
      
      override public function show() : void
      {
         if(m_closeButton != null)
         {
            m_closeButton.visible = !this.m_hideCloseButton;
         }
         super.show();
      }
   }
}

