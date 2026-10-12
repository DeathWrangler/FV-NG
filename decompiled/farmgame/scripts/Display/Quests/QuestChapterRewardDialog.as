package Display.Quests
{
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.view.BaseWidgetView;
   import com.troyer.widget.view.TextFieldView;
   
   public class QuestChapterRewardDialog extends QuestRewardDialog
   {
      
      public function QuestChapterRewardDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function setup() : void
      {
         super.setup();
         this.setupBigRewardImage();
      }
      
      private function setupBigRewardImage() : void
      {
         this.setShortcutAttribute("bigRewardImage",ImageController.ATTRIBUTE_SOURCE,m_questObject.chapterRewardImage);
      }
      
      override protected function setUpRewards() : void
      {
         var rewardListLength:int = int(m_rewardList.length);
         if(rewardListLength > 0)
         {
            this.setShortcutAttribute("additionalPrize1Image",ImageController.ATTRIBUTE_SOURCE,m_rewardList[0].url);
            this.setShortcutAttribute("additionalPrize1Text",TextFieldView.ATTRIBUTE_TEXT,m_rewardList[0].quantity);
         }
         else
         {
            this.setShortcutAttribute("additionalRewards",BaseWidgetView.ATTRIBUTE_VISIBLE,false);
         }
         if(rewardListLength > 1)
         {
            this.setShortcutAttribute("additionalPrize2Image",ImageController.ATTRIBUTE_SOURCE,m_rewardList[1].url);
            this.setShortcutAttribute("additionalPrize2Text",TextFieldView.ATTRIBUTE_TEXT,m_rewardList[1].quantity);
         }
      }
      
      override protected function getAvatarImage() : String
      {
         return m_questObject.avatarHeadImage;
      }
      
      override protected function setUpHeaderTexts() : void
      {
         this.setShortcutAttribute("rewardMessageText",TextFieldView.ATTRIBUTE_TEXT,m_questObject.chapterRewardTitle);
         this.setShortcutAttribute("rewardInfoText",TextFieldView.ATTRIBUTE_TEXT,m_questObject.chapterRewardInfo);
      }
   }
}

