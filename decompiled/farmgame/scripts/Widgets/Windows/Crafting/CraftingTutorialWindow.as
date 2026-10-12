package Widgets.Windows.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class CraftingTutorialWindow extends FarmWindow
   {
      
      private var m_craftType:String = "";
      
      private var m_acceptCallback:Function = null;
      
      private var m_closeCallback:Function = null;
      
      private var m_tutorialBeginFrame:ZwFrame = null;
      
      private var m_avatarMessageFrame:ZwFrame = null;
      
      public function CraftingTutorialWindow(craftType:String, acceptCallback:Function, closeCallback:Function)
      {
         super("assets/dialogs/FV_Craft_tutorial_dialog.swf");
         this.m_craftType = craftType;
         this.m_acceptCallback = acceptCallback;
         this.m_closeCallback = closeCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         var goodItem:FarmItem = Global.craftConfigSettings.getTutorialRecipeItem(this.m_craftType);
         var bushelItem:FarmItem = Global.craftConfigSettings.getTutorialBushelItem(this.m_craftType);
         this.m_tutorialBeginFrame = new ZwFrame(m_window.tutorialBegin_mc);
         this.m_tutorialBeginFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.generic_tf,this.getIntroTitleText()));
         this.m_tutorialBeginFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.description1_tf,ZLocUtils.t("Crafting","CraftingTutorial_IntroGetBushelsFromFriends")));
         this.m_tutorialBeginFrame.addWidget(new FarmIcon(m_window.tutorialBegin_mc.icon1_mc,bushelItem.icon));
         this.m_tutorialBeginFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.itemTitle1_tf,ZLocUtils.tk_pk_asTitle(bushelItem.friendlyName)));
         this.m_tutorialBeginFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.description2_tf,ZLocUtils.t("Crafting","CraftingTutorial_IntroUseEmToMakeGoods")));
         this.m_tutorialBeginFrame.addWidget(new FarmIcon(m_window.tutorialBegin_mc.icon2_mc,goodItem.icon));
         this.m_tutorialBeginFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.itemTitle2_tf,ZLocUtils.tk_pk_asTitle(goodItem.friendlyName)));
         this.m_tutorialBeginFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.description3_tf,ZLocUtils.t("Crafting","CraftingTutorial_IntroUseGoodsForFuel")));
         this.m_tutorialBeginFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.itemTitle3_tf,ZLocUtils.t("Crafting","CraftingTutorial_IntroFuel")));
         this.m_avatarMessageFrame = new ZwFrame(m_window.tutorialBegin_mc.avatarMessage_mc);
         this.m_avatarMessageFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.avatarMessage_mc.generic_tf,ZLocUtils.t("Crafting","CraftingTutorial_IntroMessage1")));
         this.m_avatarMessageFrame.addWidget(new ZwTextField(m_window.tutorialBegin_mc.avatarMessage_mc.generic2_tf,ZLocUtils.t("Crafting","CraftingTutorial_IntroMessage2")));
         this.m_avatarMessageFrame.addWidget(new FarmAnimatedTextButton(m_window.tutorialBegin_mc.avatarMessage_mc.cancel_bt,ZLocUtils.t("Crafting","CraftingTutorial_IntroSkipIt"),this.onClose));
         this.m_avatarMessageFrame.addWidget(new FarmAnimatedTextButton(m_window.tutorialBegin_mc.avatarMessage_mc.accept_bt,ZLocUtils.t("Crafting","CraftingTutorial_IntroGetStarted"),this.onAccept));
         addWidget(this.m_tutorialBeginFrame);
         addWidget(this.m_avatarMessageFrame);
      }
      
      private function getIntroTitleText() : String
      {
         var failoverEntryArray:Array = new Array(new ZLocFailoverEntry("Crafting","CraftingTutorial_IntroTitle_" + this.m_craftType),new ZLocFailoverEntry("Crafting","CraftingTutorial_IntroTitle_failoverDefault"));
         var buildingFriendlyNameKey:String = CraftingManager.getInstance().getCottageFriendlyNameByCraft(this.m_craftType);
         var buildingFriendlyName:String = ZLocUtils.tk_pk_asTitle(buildingFriendlyNameKey);
         return ZLocUtils.getFailoverLocString(failoverEntryArray,{"building_name":buildingFriendlyName});
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_acceptCallback = null;
         this.m_tutorialBeginFrame = null;
         this.m_avatarMessageFrame = null;
      }
      
      protected function onAccept(event:Event) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback();
         }
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         close();
      }
   }
}

