from src.models.db_entities import Journal

class MemoProcessor:
    """Journals 데이터를 분석 가능한 형태로 변환하는 클래스"""
    
    def process(self, journal: Journal) -> dict:
        """
        Journal 엔티티를 받아서 분석 타입과 데이터를 추출하여 반환한다.
        """
        content = journal.content.strip() if journal.content else ""
        voice_url = journal.voice_url
        
        memo_type = "text"
        if content and voice_url:
            memo_type = "mixed"
        elif voice_url:
            memo_type = "voice"
        
        return {
            "journal_id": journal.journal_id,
            "user_id": journal.user_id,
            "type": memo_type,
            "content": content,
            "voice_url": voice_url,
            "created_at": journal.created_at
        }
