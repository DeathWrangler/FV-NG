package Widgets.Slots.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.*;
   import gs.TweenLite;
   
   public class TutorialOnePageSlot extends ZwSlotFrame
   {
      
      private var m_detailsMC:MovieClip;
      
      private var m_detailsFrame:ZwFrame;
      
      private var m_overviewMC:MovieClip;
      
      private var m_overviewFrame:ZwFrame;
      
      private var m_buttonUrl:String;
      
      private var m_localizationBundle:String = "Crafting";
      
      public function TutorialOnePageSlot(element:DisplayObject)
      {
         super(element);
         this.registerEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         this.registerEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.m_detailsMC = m_element.details_mc;
         this.m_detailsFrame = new ZwFrame(this.m_detailsMC);
         addWidget(this.m_detailsFrame,false);
         this.m_detailsFrame.addWidget(new ZwTextField(this.m_detailsMC.generic_tf,""));
         this.m_detailsFrame.addWidget(new ZwTextField(this.m_detailsMC.generic1_tf,""));
         this.m_detailsFrame.addWidget(new FarmAnimatedTextButton(this.m_detailsMC.learn_bt,"",this.onClick));
         this.m_overviewMC = m_element.overview_mc;
         this.m_overviewFrame = new ZwFrame(this.m_overviewMC);
         addWidget(this.m_overviewFrame,true);
         this.m_overviewFrame.addWidget(new ZwTextField(this.m_overviewMC.generic_tf,""));
         this.m_overviewFrame.addWidget(new ZwTextField(this.m_overviewMC.rollover_tf,ZLocUtils.t("Crafting","Tutorial_Rollover")));
         this.m_overviewFrame.addWidget(new FarmIcon(this.m_overviewMC.image_mc),false);
      }
      
      override public function populate(tutorialItem:Object) : void
      {
         super.populate(tutorialItem);
         if(tutorialItem.localiztionBundle)
         {
            this.m_localizationBundle = tutorialItem.localiztionBundle;
         }
         var detailTitle:ZwTextField = this.m_detailsFrame.getWidget(this.m_detailsMC.generic_tf) as ZwTextField;
         detailTitle.text = ZLocUtils.t(this.m_localizationBundle,tutorialItem.title,tutorialItem.params);
         detailTitle.visible = true;
         var detailBody:ZwTextField = this.m_detailsFrame.getWidget(this.m_detailsMC.generic1_tf) as ZwTextField;
         detailBody.text = ZLocUtils.t(this.m_localizationBundle,tutorialItem.body,tutorialItem.params);
         detailBody.visible = true;
         this.m_buttonUrl = tutorialItem.buttonUrl;
         var button:FarmAnimatedTextButton = this.m_detailsFrame.getWidget(this.m_detailsMC.learn_bt) as FarmAnimatedTextButton;
         if(this.m_buttonUrl != "")
         {
            button.text = ZLocUtils.t(this.m_localizationBundle,tutorialItem.buttonTitle,tutorialItem.params);
            button.visible = true;
         }
         else
         {
            button.text = "";
            button.visible = false;
         }
         var overviewTitle:ZwTextField = this.m_overviewFrame.getWidget(this.m_detailsMC.generic_tf) as ZwTextField;
         overviewTitle.text = ZLocUtils.t(this.m_localizationBundle,tutorialItem.overview,tutorialItem.params);
         overviewTitle.visible = true;
         var overviewImage:FarmIcon = this.m_overviewFrame.getWidget(this.m_overviewMC.image_mc) as FarmIcon;
         if(tutorialItem.imageUrl != "")
         {
            overviewImage.loadIcon(tutorialItem.imageUrl);
            overviewImage.visible = true;
         }
         this.m_detailsMC.visible = true;
         this.m_detailsMC.alpha = 0;
         this.m_detailsMC.mouseEnabled = false;
         this.m_detailsMC.mouseChildren = true;
         this.m_overviewMC.visible = true;
         this.m_overviewMC.alpha = 1;
         this.m_overviewMC.mouseEnabled = false;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_detailsMC = null;
         this.m_detailsFrame = null;
         this.m_overviewMC = null;
         this.m_overviewFrame = null;
         this.m_buttonUrl = null;
      }
      
      private function onClick(evt:MouseEvent) : void
      {
         navigateToURL(new URLRequest(this.m_buttonUrl));
      }
      
      private function onOver(evt:MouseEvent) : void
      {
         TweenLite.to(this.m_detailsMC,0.5,{"alpha":1});
         TweenLite.to(this.m_overviewMC,0.5,{"alpha":0});
      }
      
      private function onOut(evt:MouseEvent) : void
      {
         TweenLite.to(this.m_detailsMC,0.5,{"alpha":0});
         TweenLite.to(this.m_overviewMC,0.5,{"alpha":1});
      }
   }
}

