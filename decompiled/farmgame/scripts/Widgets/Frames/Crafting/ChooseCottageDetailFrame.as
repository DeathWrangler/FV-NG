package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Crafting.ChooseCottageWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ChooseCottageDetailFrame extends ZwFrame
   {
      
      private const BUSHEL_ICON_SIZE:int = 85;
      
      private var m_mainWindow:ChooseCottageWindow;
      
      private var m_craftType:String;
      
      public function ChooseCottageDetailFrame(element:MovieClip, mainWindow:ChooseCottageWindow)
      {
         super(element);
         this.m_mainWindow = mainWindow;
         var descriptionFrame:ZwFrame = new ZwFrame(element.description_mc);
         descriptionFrame.addWidget(new ZwTextField(element.description_mc.generic_tf,ZLocUtils.t("Crafting","ChooseCraftGoodsDesc1")));
         descriptionFrame.addWidget(new ZwTextField(element.description_mc.generic2_tf,ZLocUtils.t("Crafting","ChooseCraftGoodsDesc2")));
         addWidget(descriptionFrame);
         var recipesFrame:ZwFrame = new ZwFrame(element.recipes_mc);
         recipesFrame.addWidget(new ZwTextField(element.recipes_mc.generic_tf,ZLocUtils.t("Crafting","ChooseCraftRecipesTitle")));
         addWidget(recipesFrame);
         var avatarFrame:ZwFrame = new ZwFrame(element.avatarMessage_mc);
         avatarFrame.addWidget(new ZwTextField(element.avatarMessage_mc.generic_tf,ZLocUtils.t("Crafting","ChooseCraftAvatarMessage")));
         addWidget(avatarFrame);
         addWidget(new FarmAnimatedTextButton(element.choose_bt,ZLocUtils.t("Crafting","ChooseCraftSignUp"),this.onAccept));
         addWidget(new FarmAnimatedTextButton(element.chooseAnother_bt,ZLocUtils.t("Crafting","ChooseCraftChooseAnother"),this.onCancel));
         addWidget(new ZwButton(element.close_bt,this.onClose));
      }
      
      public function setCraftType(craftType:String) : void
      {
         this.m_craftType = craftType;
         removeWidget(m_element.description_mc.bushelIcon_mc);
         removeWidget(m_element.description_mc.goodIcon_mc);
         var bushelIcon:FarmIcon = new FarmIcon(m_element.description_mc.bushelIcon_mc,Global.farmGameSettingsManager.getString("craftingSampleBushelIcon_" + craftType));
         bushelIcon.setIconSize(this.BUSHEL_ICON_SIZE,this.BUSHEL_ICON_SIZE);
         addWidget(bushelIcon);
         var goodsIcon:FarmIcon = new FarmIcon(m_element.description_mc.goodIcon_mc,Global.farmGameSettingsManager.getString("craftingSampleGoodsIcon_" + craftType));
         goodsIcon.setIconSize(this.BUSHEL_ICON_SIZE,this.BUSHEL_ICON_SIZE);
         addWidget(goodsIcon);
         removeWidget(m_element.recipes_mc.slot_0_mc);
         addWidget(new ChooseCottageRecipeFrame(m_element.recipes_mc.slot_0_mc,this.m_craftType,0));
         removeWidget(m_element.recipes_mc.slot_1_mc);
         addWidget(new ChooseCottageRecipeFrame(m_element.recipes_mc.slot_1_mc,this.m_craftType,1));
         removeWidget(m_element.recipes_mc.slot_2_mc);
         addWidget(new ChooseCottageRecipeFrame(m_element.recipes_mc.slot_2_mc,this.m_craftType,2));
         removeWidget(m_element.recipes_mc.slot_3_mc);
         addWidget(new ChooseCottageRecipeFrame(m_element.recipes_mc.slot_3_mc,this.m_craftType,3));
      }
      
      private function onAccept(event:Event) : void
      {
         this.m_mainWindow.close();
         CraftingManager.getInstance().claimFreeCottage(this.m_craftType);
      }
      
      private function onCancel(event:Event) : void
      {
         this.m_mainWindow.showOverviewFrame();
      }
      
      protected function onClose(event:Event) : void
      {
         this.m_mainWindow.showOverviewFrame();
      }
   }
}

