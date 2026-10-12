package Display
{
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LevelUpWindow extends FarmWindow
   {
      
      protected var m_level:int = 1;
      
      private var m_okCallback:Function;
      
      private var m_checkMark:MovieClip = null;
      
      private var m_checkBox:FarmAnimatedButton = null;
      
      private var m_selected:Boolean = true;
      
      public function LevelUpWindow(windowAssetRelUrl:String, newLevel:int, shareCallback:Function = null, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         this.m_level = newLevel;
         this.m_okCallback = shareCallback;
         super(windowAssetRelUrl,modal,bAddClickBlocker);
      }
      
      public function onClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = this.m_selected = !this.m_selected;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var masteryRewardCheckboxText:String = null;
         var buttonString:String = null;
         super.onLoadComplete(event);
         var checkBoxFlow:Boolean = false;
         if(m_window.hasOwnProperty("checkbox_tf"))
         {
            masteryRewardCheckboxText = ZLocUtils.t("Dialogs","MasteryRewardCheckboxText");
            addWidget(new ZwTextField(m_window.checkbox_tf,masteryRewardCheckboxText));
            this.m_checkMark = m_window.checkMark_mc as MovieClip;
            this.m_checkMark.mouseEnabled = true;
            this.m_checkMark.visible = this.m_selected = true;
            this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onClick);
            this.m_checkBox = addWidget(new FarmAnimatedButton(m_window.checkBox_mc,this.onClick)) as FarmAnimatedButton;
            checkBoxFlow = true;
         }
         if(ObjectUtil.pathExists(m_window,["congrats_mc"]))
         {
            m_window.congrats_mc.text = ZLocUtils.t("Dialogs","Congratulations");
         }
         if(this.m_level < 101)
         {
            if(ObjectUtil.pathExists(m_window,["level_mc","generic_tf"]))
            {
               m_window.level_mc.generic_tf.text = ZLocUtils.t("Dialogs","NewLevel",{"quantity":this.m_level});
            }
            if(ObjectUtil.pathExists(m_window,["name_mc","generic_tf"]))
            {
               m_window.name_mc.generic_tf.text = ZLocUtils.t("Levels","Level" + this.m_level);
            }
            if(ObjectUtil.pathExists(m_window,["known_mc","generic_tf"]))
            {
               m_window.known_mc.generic_tf.text = ZLocUtils.t("Dialogs","KnownAs");
            }
            if(ObjectUtil.pathExists(m_window,["highLevel_mc"]))
            {
               m_window.highLevel_mc.visible = false;
            }
         }
         else
         {
            if(ObjectUtil.pathExists(m_window,["name_mc"]))
            {
               m_window.name_mc.visible = false;
            }
            if(ObjectUtil.pathExists(m_window,["known_mc","generic_tf"]))
            {
               m_window.known_mc.visible = false;
            }
            if(ObjectUtil.pathExists(m_window,["highLevel_mc","generic_tf"]))
            {
               m_window.highLevel_mc.generic_tf.text = ZLocUtils.t("Dialogs","LevelOver100",{"level":this.m_level});
            }
         }
         if(ObjectUtil.pathExists(m_window,["ok_bt"]))
         {
            buttonString = null;
            if(checkBoxFlow)
            {
               buttonString = ZLocUtils.t("Dialogs","Continue");
            }
            else
            {
               buttonString = ZLocUtils.t("Dialogs","Share");
            }
            addWidget(new FarmAnimatedTextButton(m_window.ok_bt,buttonString,this.onOkClick));
         }
         m_window.play();
         TweenLite.to(m_window.ok_bt,0,{"alpha":1});
         TweenLite.from(m_window.ok_bt,0.5,{
            "alpha":0,
            "delay":1,
            "ease":Back.easeOut
         });
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_okCallback = null;
      }
      
      private function onOkClick(event:MouseEvent) : void
      {
         if(this.selected && this.m_okCallback != null)
         {
            this.m_okCallback(event);
         }
         close();
      }
   }
}

