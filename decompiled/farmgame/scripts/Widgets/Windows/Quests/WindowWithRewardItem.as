package Widgets.Windows.Quests
{
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class WindowWithRewardItem extends FarmWindow
   {
      
      public static const PREVIEWWIDTH:Number = 125;
      
      private var m_shareBt:FarmAnimatedButton = null;
      
      private var m_farmItem:FarmItem;
      
      public function WindowWithRewardItem(assetUrl:String, farmItem:FarmItem = null)
      {
         super(assetUrl);
         this.m_farmItem = farmItem;
      }
      
      protected function getTitle() : String
      {
         return "";
      }
      
      protected function getRewardText() : String
      {
         return "";
      }
      
      protected function getRewardShareButtonText() : String
      {
         return "";
      }
      
      protected function getExtraRewardText() : String
      {
         return "";
      }
      
      protected function getRewardButtonText() : String
      {
         return "Share";
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var titleText:String = this.getTitle();
         var rewardText:String = this.getRewardText();
         var rewardShareButtonText:String = this.getRewardShareButtonText();
         var extraRewardText:String = this.getExtraRewardText();
         if(m_window.mainWindow)
         {
            addWidget(new ZwFrame(m_window.mainWindow));
         }
         this.showRewardItem(this.m_farmItem);
         if(m_window.title_tf)
         {
            addWidget(new ZwTextField(m_window.title_tf,titleText));
         }
         else if(m_window.mainWindow.title_tf)
         {
            addWidget(new ZwTextField(m_window.mainWindow.title_tf,titleText));
         }
         if(m_window.generic_tf)
         {
            addWidget(new ZwTextField(m_window.generic_tf,rewardText));
         }
         else if(m_window.mainWindow.generic_tf)
         {
            addWidget(new ZwTextField(m_window.mainWindow.generic_tf,rewardText));
         }
         if(m_window.generic2_tf)
         {
            addWidget(new ZwTextField(m_window.generic2_tf,rewardShareButtonText));
         }
         else if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.generic2_tf))
         {
            addWidget(new ZwTextField(m_window.mainWindow.generic2_tf,rewardShareButtonText));
         }
         if(extraRewardText != "")
         {
            if(m_window.generic3_tf)
            {
               addWidget(new ZwTextField(m_window.generic3_tf,extraRewardText));
            }
            else if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.generic3_tf))
            {
               addWidget(new ZwTextField(m_window.mainWindow.generic3_tf,extraRewardText));
            }
         }
         if(m_window.share_bt)
         {
            this.m_shareBt = addWidget(new FarmAnimatedTextButton(m_window.share_bt,this.getRewardButtonText(),this.onShareClick)) as FarmAnimatedButton;
         }
         else if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.share_bt))
         {
            this.m_shareBt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.share_bt,this.getRewardButtonText(),this.onShareClick)) as FarmAnimatedButton;
         }
      }
      
      protected function showRewardItem(farmItem:FarmItem) : void
      {
         var itemPreview:ObjectPreviewFrame = null;
         var icon_mc:String = "icon_mc";
         var icon_tf:String = "icon_tf";
         if(Boolean(m_window[icon_mc]) && farmItem != null)
         {
            itemPreview = new ObjectPreviewFrame(m_window[icon_mc],farmItem,null,null,[PREVIEWWIDTH]);
            itemPreview.y += PREVIEWWIDTH / 2;
            addWidget(itemPreview);
         }
      }
      
      protected function onShareClick(event:MouseEvent) : void
      {
         this.m_shareBt.enabled = false;
         close();
      }
   }
}

