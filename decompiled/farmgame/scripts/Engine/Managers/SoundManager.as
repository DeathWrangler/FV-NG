package Engine.Managers
{
   import Engine.Classes.SoundObject;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class SoundManager
   {
      
      protected static var m_sounds:Dictionary = new Dictionary();
      
      protected static var m_activeChannels:Array = [];
      
      protected static var m_isMuted:Boolean = false;
      
      public function SoundManager()
      {
         super();
      }
      
      public static function addSound(param1:String, param2:String, param3:Boolean = true, param4:Function = null) : Sound
      {
         var sound:Sound = null;
         var onLoadCompleteWrapper:Function = null;
         var errorMessage:String = null;
         var id:String = param1;
         var url:String = param2;
         var playOnLoad:Boolean = param3;
         var onLoadComplete:Function = param4;
         sound = m_sounds[id];
         if(sound == null)
         {
            if(Boolean(url) && url != "null")
            {
               sound = new Sound();
               sound.addEventListener(Event.COMPLETE,onComplete);
               if(playOnLoad)
               {
                  sound.addEventListener(Event.COMPLETE,onPlayOnComplete);
               }
               if(onLoadComplete != null)
               {
                  onLoadCompleteWrapper = function(param1:Event):void
                  {
                     onLoadComplete(param1);
                     sound.removeEventListener(Event.COMPLETE,onLoadCompleteWrapper);
                  };
                  sound.addEventListener(Event.COMPLETE,onLoadCompleteWrapper);
               }
               sound.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
               sound.load(new URLRequest(AssetUrlManager.instance.lookUpUrl(url)));
               m_sounds[id] = sound;
               GlobalEngine.log("Sound","Add sound, id: " + id + ", url: " + url);
            }
            else
            {
               errorMessage = "SoundManager.addSound - URL is empty.";
               errorMessage += ",soundId=" + id;
               ErrorManager.addError(errorMessage);
            }
         }
         return sound;
      }
      
      protected static function onComplete(param1:Event) : void
      {
         var _loc2_:Sound = param1.target as Sound;
         GlobalEngine.log("Sound","Sound loaded: " + _loc2_.url);
      }
      
      protected static function onIOError(param1:Event) : void
      {
         var _loc2_:String = "SoundManager.onIOError - Error loading sound.";
         var _loc3_:Sound = param1.target as Sound;
         if(_loc3_)
         {
            _loc2_ += ",url=" + _loc3_.url;
         }
         ErrorManager.addError(_loc2_,ErrorManager.ERROR_LOAD_IO_ERROR);
      }
      
      public static function playSound(param1:String, param2:Number = 0, param3:int = 0, param4:SoundTransform = null, param5:Boolean = false, param6:Function = null) : SoundObject
      {
         var _loc7_:Sound = getSoundById(param1);
         var _loc8_:SoundObject = null;
         GlobalEngine.log("Sound","Play Sound: " + param1 + " (muted: " + isMuted() + ")");
         if(Boolean(_loc7_) && _loc7_.bytesLoaded == _loc7_.bytesTotal)
         {
            _loc8_ = conditionallyPlaySound(_loc7_,param2,param3,param4,param5,param6);
         }
         return _loc8_;
      }
      
      public static function addOrPlaySound(param1:String, param2:String) : void
      {
         if(getSoundById(param1) != null)
         {
            playSound(param1);
         }
         else
         {
            addSound(param1,param2,true);
         }
      }
      
      public static function stopSound(param1:String) : void
      {
         var _loc2_:Sound = getSoundById(param1);
         var _loc3_:SoundObject = getSoundObject(_loc2_);
         if(_loc3_ != null)
         {
            _loc3_.stop();
         }
      }
      
      public static function getSoundObject(param1:Sound) : SoundObject
      {
         var _loc4_:int = 0;
         var _loc5_:SoundObject = null;
         var _loc2_:SoundObject = null;
         var _loc3_:Boolean = false;
         if(GlobalEngine.getFlashVar("soundOptimizedCheck") == "true")
         {
            _loc3_ = true;
         }
         if(param1 != null)
         {
            _loc4_ = 0;
            while(_loc4_ < m_activeChannels.length)
            {
               _loc5_ = m_activeChannels[_loc4_] as SoundObject;
               if(_loc3_)
               {
                  if(_loc5_.sound == param1)
                  {
                     _loc2_ = _loc5_;
                     break;
                  }
               }
               else if(_loc5_.sound.url == param1.url)
               {
                  _loc2_ = _loc5_;
                  break;
               }
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      private static function conditionallyPlaySound(param1:Sound, param2:Number = 0, param3:int = 0, param4:SoundTransform = null, param5:Boolean = false, param6:Function = null) : SoundObject
      {
         var soundChannel:SoundChannel = null;
         var errorMessage:String = null;
         var onSoundCompleteWrapper:Function = null;
         var sound:Sound = param1;
         var startTime:Number = param2;
         var loops:int = param3;
         var transform:SoundTransform = param4;
         var isMusic:Boolean = param5;
         var onSoundCompleteCallBack:Function = param6;
         var result:SoundObject = null;
         if(isMusic == true || isMuted() == false || loops > 0)
         {
            try
            {
               soundChannel = sound.play(startTime,loops,transform);
            }
            catch(e:Error)
            {
               errorMessage = "SoundManager.conditionallyPlaySound - Failed to play sound.";
               errorMessage += ",url=" + sound.url;
               ErrorManager.addError(errorMessage);
            }
            if(soundChannel)
            {
               result = new SoundObject(sound,soundChannel);
               result.isMusic = isMusic;
               m_activeChannels.push(result);
               sound.addEventListener(Event.SOUND_COMPLETE,onSoundComplete);
               if(onSoundCompleteCallBack != null)
               {
                  onSoundCompleteWrapper = function(param1:Event):void
                  {
                     onSoundCompleteCallBack(param1);
                     sound.removeEventListener(Event.SOUND_COMPLETE,onSoundCompleteWrapper);
                  };
                  sound.addEventListener(Event.SOUND_COMPLETE,onSoundCompleteWrapper);
               }
               if(!isMusic && isMuted())
               {
                  result.volume = 0;
               }
            }
         }
         return result;
      }
      
      private static function onSoundComplete(param1:Event) : void
      {
         var _loc2_:Sound = param1.target as Sound;
         var _loc3_:SoundObject = getSoundObject(_loc2_);
         if(_loc3_ != null)
         {
            m_activeChannels.splice(m_activeChannels.indexOf(_loc3_),1);
         }
      }
      
      private static function onPlayOnComplete(param1:Event) : void
      {
         var _loc2_:Sound = param1.target as Sound;
         _loc2_.removeEventListener(Event.COMPLETE,onPlayOnComplete);
         if(_loc2_)
         {
            conditionallyPlaySound(_loc2_);
         }
      }
      
      public static function getSoundById(param1:String) : Sound
      {
         return m_sounds[param1] as Sound;
      }
      
      public static function mute() : void
      {
         var _loc2_:SoundObject = null;
         m_isMuted = true;
         var _loc1_:int = 0;
         while(_loc1_ < m_activeChannels.length)
         {
            _loc2_ = m_activeChannels[_loc1_] as SoundObject;
            if(Boolean(_loc2_) && _loc2_.isMusic == false)
            {
               _loc2_.volume = 0;
            }
            _loc1_++;
         }
      }
      
      public static function unmute() : void
      {
         var _loc2_:SoundObject = null;
         m_isMuted = false;
         var _loc1_:int = 0;
         while(_loc1_ < m_activeChannels.length)
         {
            _loc2_ = m_activeChannels[_loc1_] as SoundObject;
            if(Boolean(_loc2_) && _loc2_.isMusic == false)
            {
               _loc2_.volume = 1;
            }
            _loc1_++;
         }
      }
      
      public static function isMuted() : Boolean
      {
         return m_isMuted;
      }
      
      public static function chooseAndPlaySound(param1:Array) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:String = null;
         if(param1.length == 1)
         {
            _loc2_ = param1[0] as String;
         }
         else if(param1.length > 0)
         {
            _loc3_ = Math.floor(Math.random() * param1.length);
            _loc2_ = param1[_loc3_] as String;
         }
         if(_loc2_ != null)
         {
            playSound(_loc2_);
         }
      }
   }
}

