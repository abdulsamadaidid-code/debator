insert into public.topics (id, name, tagline, description, sort_order)
values
  ('religion', 'Religion', 'Doctrine, scripture, and meaning.', 'Arguments about faith, theology, comparative religion, and spiritual claims.', 10),
  ('science', 'Science', 'Claims that survive evidence.', 'Debates about physics, biology, medicine, climate, and the scientific method.', 20),
  ('philosophy', 'Philosophy', 'Logic, consciousness, and truth.', 'Metaphysics, epistemology, free will, identity, and the structure of arguments.', 30),
  ('politics', 'Politics', 'Power, policy, and public systems.', 'Political theory, government design, voting systems, and current policy.', 40),
  ('ethics', 'Ethics', 'What should we permit or prohibit?', 'Moral frameworks, social dilemmas, justice, fairness, and applied ethics.', 50),
  ('technology', 'Technology', 'Innovation with tradeoffs.', 'AI, software, privacy, platforms, hardware, and the effect of tools on society.', 60),
  ('history', 'History', 'Interpretation shaped by evidence.', 'Historical causation, revisionism, legacy, and lessons from past events.', 70),
  ('culture', 'Culture', 'Stories, values, and identity.', 'Media, norms, language, education, and how communities define themselves.', 80),
  ('sports', 'Sports', 'Competition deserves analysis too.', 'Rules, strategy, officiating, player legacy, and how sport changes over time.', 90),
  ('economics', 'Economics', 'Markets, incentives, and inequality.', 'Growth, labor, redistribution, scarcity, and what efficient systems should optimize.', 100)
on conflict (id) do update
set
  name = excluded.name,
  tagline = excluded.tagline,
  description = excluded.description,
  sort_order = excluded.sort_order;
